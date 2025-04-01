const Category = require('../models/category.model');
const db = require('../config/database');

const getCategoriesByUserId = (userId) => {
  return new Promise((resolve, reject) => {
    Category.findByUserId(userId, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results);
      }
    });
  });
};

const getCategoryByIdAndUserId = (id, userId) => {
  return new Promise((resolve, reject) => {
    Category.findByIdAndUserId(id, userId, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve(results[0]);
      }
    });
  });
};

const createCategory = (category) => {
  return new Promise((resolve, reject) => {
    Category.create(category, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id: results.insertId, ...category });
      }
    });
  });
};

const updateCategory = (id, category) => {
  return new Promise((resolve, reject) => {
    Category.update(id, category, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve({ id, ...category });
      }
    });
  });
};

const deleteCategory = (id) => {
  return new Promise((resolve, reject) => {
    Category.delete(id, (err, results) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });
};

const createDefaultCategoriesForUser = (userId) => {
  return new Promise((resolve, reject) => {
    db.query('SELECT * FROM default_categories', (err, defaultCategories) => {
      if (err) {
        reject(err);
      } else {
        const categoriesToInsert = defaultCategories.map((category) => ({
          user_id: userId,
          name: category.name,
          type: category.type,
        }));

        db.query(
          'INSERT INTO categories (user_id, name, type) VALUES ?',
          [categoriesToInsert.map((c) => [c.user_id, c.name, c.type])],
          (err, results) => {
            if (err) {
              reject(err);
            } else {
              resolve(results);
            }
          }
        );
      }
    });
  });
};

module.exports = {
  getCategoriesByUserId,
  getCategoryByIdAndUserId,
  createCategory,
  updateCategory,
  deleteCategory,
  createDefaultCategoriesForUser,
};