const db = require('../config/database');

const Category = {
  findByUserId: (userId, callback) => {
    db.query('SELECT * FROM categories WHERE user_id = ?', [userId], callback);
  },

  findByIdAndUserId: (id, userId, callback) => {
    db.query('SELECT * FROM categories WHERE id = ? AND user_id = ?', [id, userId], callback);
  },

  create: (category, callback) => {
    db.query('INSERT INTO categories SET ?', category, callback);
  },

  update: (id, category, callback) => {
    db.query('UPDATE categories SET ? WHERE id = ?', [category, id], callback);
  },

  delete: (id, callback) => {
    db.query('DELETE FROM categories WHERE id = ?', [id], callback);
  },
};

module.exports = Category;