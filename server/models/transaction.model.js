const db = require('../config/database');

const Transaction = {
  findByUserId: (userId, accountId, categoryId, startDate, endDate, callback) => {
    let query = `
      SELECT transactions.*, categories.name as category_name, accounts.name as account_name
      FROM transactions
      JOIN categories ON transactions.category_id = categories.id
      JOIN accounts ON transactions.account_id = accounts.id
      WHERE accounts.user_id = ?
    `;
    const params = [userId];

    if (accountId) {
      query += ' AND transactions.account_id = ?';
      params.push(accountId);
    }

    if (categoryId) {
      query += ' AND transactions.category_id = ?';
      params.push(categoryId);
    }

    if (startDate) {
      query += ' AND transactions.transaction_date >= ?';
      params.push(startDate);
    }

    if (endDate) {
      query += ' AND transactions.transaction_date <= ?';
      params.push(endDate);
    }
    query += " ORDER BY transactions.transaction_date DESC";
    db.query(query, params, callback);
  },

  findByIdAndUserId: (id, userId, callback) => {
    db.query(
      `SELECT transactions.*, categories.name as category_name, accounts.name as account_name
      FROM transactions
      JOIN categories ON transactions.category_id = categories.id
      JOIN accounts ON transactions.account_id = accounts.id
      WHERE transactions.id = ? AND accounts.user_id = ?`,
      [id, userId],
      callback
    );
  },

  create: (transaction, callback) => {
    db.query('INSERT INTO transactions SET ?', transaction, callback);
  },

  update: (id, transaction, callback) => {
    db.query('UPDATE transactions SET ? WHERE id = ?', [transaction, id], callback);
  },

  delete: (id, callback) => {
    db.query('DELETE FROM transactions WHERE id = ?', [id], callback);
  },
};

module.exports = Transaction;