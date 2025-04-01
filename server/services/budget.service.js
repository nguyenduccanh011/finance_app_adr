const Budget = require('../models/budget.model');

const getBudgetsByUserId = (userId) => {
  return new Promise((resolve, reject) => {
    Budget.findByUserId(userId, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results);
      }
    });
  });
};

const getBudgetByIdAndUserId = (id, userId) => {
  return new Promise((resolve, reject) => {
    Budget.findByIdAndUserId(id, userId, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results[0]);
      }
    });
  });
};

const createBudget = (budget) => {
  return new Promise((resolve, reject) => {
    Budget.create(budget, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id: results.insertId, ...budget });
      }
    });
  });
};

const updateBudget = (id, budget) => {
  return new Promise((resolve, reject) => {
    Budget.update(id, budget, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id, ...budget });
      }
    });
  });
};

const deleteBudget = (id) => {
  return new Promise((resolve, reject) => {
    Budget.delete(id, (err, results) => {
      if (err) {
        console.error(err);   // In ra lỗi chi tiết
        reject(err);
      } else {
        resolve();
      }
    });
  });
};

// Trong budget.service.js
const getBudgetById = (id) => {
  return new Promise((resolve, reject) => {
    Budget.findById(id, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results[0]);
      }
    });
  });
};


module.exports = {
  getBudgetsByUserId,
  getBudgetByIdAndUserId,
  createBudget,
  updateBudget,
  deleteBudget,
  getBudgetById,
};