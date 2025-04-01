const db = require('../config/database');

const RecurringTransaction = {
  findById: (id, callback) => {
    db.query(
      `SELECT rt.*, a.name as account_name, c.name as category_name 
      FROM recurring_transactions rt
      JOIN accounts a ON rt.account_id = a.id
      JOIN categories c ON rt.category_id = c.id
      WHERE rt.id = ?`,
      [id],
      callback
    );
  },

  findByUserId: (userId, callback) => {
    db.query(
      `SELECT rt.*, a.name as account_name, c.name as category_name 
      FROM recurring_transactions rt
      JOIN accounts a ON rt.account_id = a.id
      JOIN categories c ON rt.category_id = c.id
      WHERE rt.user_id = ?`,
      [userId],
      callback
    );
  },

  create: (recurringTransaction, callback) => {
    db.query(
      'INSERT INTO recurring_transactions SET ?',
      recurringTransaction, // Phải đảm bảo recurringTransaction có trường type
      callback
    );
  },

  update: (id, recurringTransaction, callback) => {
    db.query(
      'UPDATE recurring_transactions SET ? WHERE id = ?',
      [recurringTransaction, id], // Phải đảm bảo recurringTransaction có trường type
      callback
    );
  },
  
  delete: (id, callback) => {
    db.query('DELETE FROM recurring_transactions WHERE id = ?', [id], callback);
  },

  findDueTransactions: (date, callback) => {
    db.query(
      `SELECT rt.*, a.name as account_name, c.name as category_name 
      FROM recurring_transactions rt
      JOIN accounts a ON rt.account_id = a.id
      JOIN categories c ON rt.category_id = c.id
      WHERE rt.next_occurrence <= ?`,
      [date],
      callback
    );
  },

  updateNextOccurrence: (id, nextOccurrence, callback) => {
    db.query(
      'UPDATE recurring_transactions SET next_occurrence = ? WHERE id = ?',
      [nextOccurrence, id],
      callback
    );
  },
};

module.exports = RecurringTransaction;