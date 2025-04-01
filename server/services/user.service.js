const User = require('../models/user.model');

const findUserById = (id) => {
  return new Promise((resolve, reject) => {
    User.findById(id, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results[0]);
      }
    });
  });
};

const findUserByUsername = (username) => {
    return new Promise((resolve, reject) => {
      User.findByUsername(username, (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve(results[0]);
        }
      });
    });
  };

  const findUserByEmail = (email) => {
    return new Promise((resolve, reject) => {
      User.findByEmail(email, (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve(results[0]);
        }
      });
    });
  };

const findUserByUsernameOrEmail = (username, email) => {
  return new Promise((resolve, reject) => {
    User.findByUsernameOrEmail(username, email, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results[0]);
      }
    });
  });
};

const createUser = (user) => {
  return new Promise((resolve, reject) => {
    User.create(user, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id: results.insertId, ...user });
      }
    });
  });
};

const updateUser = (id, user) => {
  return new Promise((resolve, reject) => {
    User.update(id, user, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id, ...user });
      }
    });
  });
};

module.exports = {
  findUserById,
  findUserByUsername,
  findUserByEmail,
  findUserByUsernameOrEmail,
  createUser,
  updateUser,
};