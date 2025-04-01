const db = require('../config/database');

const Budget = {
  findByUserId: (userId, callback) => {
    db.query(
      `SELECT budgets.*, categories.name as category_name
       FROM budgets
       JOIN categories ON budgets.category_id = categories.id
       WHERE categories.user_id = ?`,
      [userId],
      callback
    );
  },

  findByIdAndUserId: (id, userId, callback) => {
    db.query(
      `SELECT budgets.*, categories.name as category_name
       FROM budgets
       JOIN categories ON budgets.category_id = categories.id
       WHERE budgets.id = ? AND categories.user_id = ?`,
      [id, userId],
      callback
    );
  },

  create: (budget, callback) => {
    db.query('INSERT INTO budgets SET ?', budget, callback);
  },

  update: (id, budget, callback) => {
    console.log("Updating budget with ID:", id, "Data:", budget); // In ra ID và data
    db.query('UPDATE budgets SET ? WHERE id = ?', [budget, id], callback);
  },

  delete: (id, callback) => {
    db.query('DELETE FROM budgets WHERE id = ?', [id], callback);
  },

  findById: (id, callback) => {
    db.query(
      `SELECT budgets.*, categories.name as category_name
        FROM budgets
        JOIN categories ON budgets.category_id = categories.id
        WHERE budgets.id = ?`,
      [id],
      callback
    );
  },
};

module.exports = Budget;