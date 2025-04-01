const db = require('../config/database');

const User = {
  findById: (id, callback) => {
    db.query('SELECT * FROM users WHERE id = ?', [id], callback);
  },

  findByUsername: (username, callback) => {
    db.query('SELECT * FROM users WHERE username = ?', [username], callback);
  },

  findByEmail: (email, callback) => {
    db.query('SELECT * FROM users WHERE email = ?', [email], callback);
  },

  findByUsernameOrEmail: (username, email, callback) => {
    db.query(
      "SELECT * FROM users WHERE username = ? OR email = ?",
      [username, email],
      callback
    );
  },

  create: (user, callback) => {
    db.query('INSERT INTO users SET ?', user, callback);
  },

  update: (id, user, callback) => {
    db.query('UPDATE users SET ? WHERE id = ?', [user, id], callback);
  },
};

module.exports = User;