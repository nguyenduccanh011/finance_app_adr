const Account = require('../models/account.model');

const getAccountsByUserId = (userId) => {
  return new Promise((resolve, reject) => {
    Account.findByUserId(userId, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results);
      }
    });
  });
};

const getAccountByIdAndUserId = (id, userId) => {
  return new Promise((resolve, reject) => {
    Account.findByIdAndUserId(id, userId, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results[0]);
      }
    });
  });
};

const createAccount = (account) => {
  return new Promise((resolve, reject) => {
    Account.create(account, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id: results.insertId, ...account });
      }
    });
  });
};

const updateAccount = (id, account) => {
  return new Promise((resolve, reject) => {
    Account.update(id, account, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id, ...account });
      }
    });
  });
};

const deleteAccount = (id) => {
  return new Promise((resolve, reject) => {
    Account.delete(id, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });
};

module.exports = {
  getAccountsByUserId,
  getAccountByIdAndUserId,
  createAccount,
  updateAccount,
  deleteAccount,
};