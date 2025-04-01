const express = require("express");
const router = express.Router();
const budgetController = require("../controllers/budget.controller");
const authMiddleware = require("../middleware/auth.middleware");

// Lấy danh sách budget của người dùng
router.get(
  "/", 
  authMiddleware.verifyToken, 
  budgetController.getBudgetsByUserId);

// Tạo budget mới
router.post(
  "/", 
  authMiddleware.verifyToken, 
  budgetController.createBudget
);

// Lấy thông tin chi tiết budget THEO ID
router.get(
  "/:id", 
  authMiddleware.verifyToken, 
  budgetController.getBudgetById
);

// Cập nhật thông tin budget
router.put(
  "/:id", 
  authMiddleware.verifyToken, 
  budgetController.updateBudget
);

// Xóa budget
router.delete(
  "/:id", 
  authMiddleware.verifyToken, 
  budgetController.deleteBudget
);

module.exports = router;

