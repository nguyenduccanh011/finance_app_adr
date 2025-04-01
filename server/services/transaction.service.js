const Transaction = require('../models/transaction.model');

const getTransactionsByUserId = (userId, accountId, categoryId, startDate, endDate) => {
  return new Promise((resolve, reject) => {
    Transaction.findByUserId(userId, accountId, categoryId, startDate, endDate, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results);
      }
    });
  });
};

const getTransactionByIdAndUserId = (id, userId) => {
  return new Promise((resolve, reject) => {
    Transaction.findByIdAndUserId(id, userId, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results[0]);
      }
    });
  });
};

const createTransaction = (transaction) => {
  return new Promise((resolve, reject) => {
    Transaction.create(transaction, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id: results.insertId, ...transaction });
      }
    });
  });
};

const updateTransaction = (id, transaction) => {
  return new Promise((resolve, reject) => {
    Transaction.update(id, transaction, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id, ...transaction });
      }
    });
  });
};

const deleteTransaction = (id) => {
  return new Promise((resolve, reject) => {
    Transaction.delete(id, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });
};

module.exports = {
  getTransactionsByUserId,
  getTransactionByIdAndUserId,
  createTransaction,
  updateTransaction,
  deleteTransaction,
};