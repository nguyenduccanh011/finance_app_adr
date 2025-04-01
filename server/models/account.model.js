const db = require('../config/database');

const Account = {
  findByUserId: (userId, callback) => {
    db.query('SELECT * FROM accounts WHERE user_id = ?', [userId], callback);
  },

  findByIdAndUserId: (id, userId, callback) => {
    db.query('SELECT * FROM accounts WHERE id = ? AND user_id = ?', [id, userId], callback);
  },

  create: (account, callback) => {
    db.query('INSERT INTO accounts SET ?', account, callback);
  },

  update: (id, account, callback) => {
    db.query('UPDATE accounts SET ? WHERE id = ?', [account, id], callback);
  },

  delete: (id, callback) => {
    db.query('DELETE FROM accounts WHERE id = ?', [id], callback);
  },
};

module.exports = Account;