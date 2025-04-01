const RecurringTransaction = require('../models/recurring_transaction.model');
const transactionService = require('../services/transaction.service');
const db = require('../config/database');

const recurringTransactionService = {
  getRecurringTransactionsByUserId: (userId) => {
    return new Promise((resolve, reject) => {
      RecurringTransaction.findByUserId(userId, (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve(results);
        }
      });
    });
  },

  getRecurringTransactionById: (id) => {
    return new Promise((resolve, reject) => {
      RecurringTransaction.findById(id, (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve(results[0]);
        }
      });
    });
  },

  createRecurringTransaction: (recurringTransaction) => {
    return new Promise((resolve, reject) => {
        // Thêm user_id vào recurringTransaction trước khi lưu vào database

        // Tính toán next_occurrence dựa trên start_date và frequency
        recurringTransaction.next_occurrence = recurringTransactionService.calculateNextOccurrence(
            recurringTransaction.start_date,
            recurringTransaction.frequency,
            recurringTransaction.interval
        );

        RecurringTransaction.create(recurringTransaction, (err, results) => {
            if (err) {
                reject(err);
            } else {
              // Lấy thông tin đầy đủ của recurring transaction sau khi tạo
              RecurringTransaction.findById(results.insertId, (err, fullTransaction) => {
                if (err) {
                  reject(err);
                } else {
                    //resolve({ id: results.insertId, ...recurringTransaction });
                    // Trả về thông tin đầy đủ, bao gồm account_name và category_name
                    resolve(fullTransaction[0]);
                }
              });
            }
        });
    });
},

  updateRecurringTransaction: (id, recurringTransaction) => {
    return new Promise((resolve, reject) => {
      // Tính toán lại next_occurrence nếu frequency, interval, hoặc start_date thay đổi
      if (
        recurringTransaction.frequency ||
        recurringTransaction.interval ||
        recurringTransaction.start_date
      ) {
        RecurringTransaction.findById(id, (err, results) => {
          if (err) {
            reject(err);
          } else {
            const existingTransaction = results[0];
            recurringTransaction.next_occurrence =
              recurringTransactionService.calculateNextOccurrence(
                recurringTransaction.start_date ||
                  existingTransaction.start_date,
                recurringTransaction.frequency ||
                  existingTransaction.frequency,
                recurringTransaction.interval ||
                  existingTransaction.interval
              );
            RecurringTransaction.update(
              id,
              recurringTransaction,
              (err, results) => {
                if (err) {
                  reject(err);
                } else {
                  resolve({ id, ...recurringTransaction });
                }
              }
            );
          }
        });
      } else {
        RecurringTransaction.update(id, recurringTransaction, (err, results) => {
          if (err) {
            reject(err);
          } else {
            resolve({ id, ...recurringTransaction });
          }
        });
      }
    });
  },

  deleteRecurringTransaction: (id) => {
    return new Promise((resolve, reject) => {
      RecurringTransaction.delete(id, (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  },

  calculateNextOccurrence: (startDate, frequency, interval) => {
    const now = new Date();
    const nextOccurrence = new Date(startDate);

    switch (frequency) {
      case 'daily':
        while (nextOccurrence <= now) {
          nextOccurrence.setDate(nextOccurrence.getDate() + interval);
        }
        break;
      case 'weekly':
        while (nextOccurrence <= now) {
          nextOccurrence.setDate(nextOccurrence.getDate() + interval * 7);
        }
        break;
      case 'monthly':
        while (nextOccurrence <= now) {
          nextOccurrence.setMonth(nextOccurrence.getMonth() + interval);
        }
        break;
      case 'yearly':
        while (nextOccurrence <= now) {
          nextOccurrence.setFullYear(nextOccurrence.getFullYear() + interval);
        }
        break;
      default:
        throw new Error('Invalid frequency');
    }

    return nextOccurrence;
  },

  createTransactionsFromDueRecurringTransactions: () => {
    return new Promise((resolve, reject) => {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      db.beginTransaction((err) => {
        if (err) {
          reject(err);
          return;
        }

        RecurringTransaction.findDueTransactions(
          today,
          (err, dueTransactions) => {
            if (err) {
              return db.rollback(() => reject(err));
            }

            const createTransactionPromises = dueTransactions.map(
              (recurringTransaction) => {
                return new Promise((resolve, reject) => {
                  const transactionData = {
                    account_id: recurringTransaction.account_id,
                    category_id: recurringTransaction.category_id,
                    amount: recurringTransaction.amount,
                    description: recurringTransaction.description,
                    transaction_date: recurringTransaction.next_occurrence,
                  };

                  transactionService
                    .createTransaction(transactionData)
                    .then(() => {
                      const nextOccurrence =
                        recurringTransactionService.calculateNextOccurrence(
                          recurringTransaction.next_occurrence,
                          recurringTransaction.frequency,
                          recurringTransaction.interval
                        );

                      if (
                        recurringTransaction.end_date &&
                        nextOccurrence > recurringTransaction.end_date
                      ) {
                        RecurringTransaction.delete(
                          recurringTransaction.id,
                          (err) => {
                            if (err) {
                              reject(err);
                            } else {
                              resolve();
                            }
                          }
                        );
                      } else {
                        RecurringTransaction.updateNextOccurrence(
                          recurringTransaction.id,
                          nextOccurrence,
                          (err) => {
                            if (err) {
                              reject(err);
                            } else {
                              resolve();
                            }
                          }
                        );
                      }
                    })
                    .catch(reject);
                });
              }
            );

            Promise.all(createTransactionPromises)
              .then(() => {
                db.commit((err) => {
                  if (err) {
                    return db.rollback(() => reject(err));
                  }
                  resolve();
                });
              })
              .catch((err) => {
                db.rollback(() => reject(err));
              });
          }
        );
      });
    });
  },
};

module.exports = recurringTransactionService;