const express = require("express");
const router = express.Router();
const categoryController = require("../controllers/category.controller");
const authMiddleware = require("../middleware/auth.middleware");

// Lấy danh sách danh mục
router.get(
  "/",
  authMiddleware.verifyToken,
  categoryController.getCategories
);
// Tạo danh mục mới
router.post(
  "/",
  authMiddleware.verifyToken,
  categoryController.createCategory
);
// Lấy thông tin chi tiết danh mục
router.get(
  "/:id",
  authMiddleware.verifyToken,
  categoryController.getCategoryById
);
// Cập nhật thông tin danh mục
router.put(
  "/:id",
  authMiddleware.verifyToken,
  categoryController.updateCategory
);
// Xóa danh mục
router.delete(
  "/:id",
  authMiddleware.verifyToken,
  categoryController.deleteCategory
);

module.exports = router;