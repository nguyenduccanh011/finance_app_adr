const express = require("express");
const router = express.Router();
const transactionController = require("../controllers/transaction.controller");
const authMiddleware = require("../middleware/auth.middleware");

// Lấy danh sách giao dịch
router.get(
  "/",
  authMiddleware.verifyToken,
  transactionController.getTransactions
);
// Tạo giao dịch mới
router.post(
  "/",
  authMiddleware.verifyToken,
  transactionController.createTransaction
);
// Lấy thông tin chi tiết giao dịch
router.get(
  "/:id",
  authMiddleware.verifyToken,
  transactionController.getTransactionById
);
// Cập nhật thông tin giao dịch
router.put(
  "/:id",
  authMiddleware.verifyToken,
  transactionController.updateTransaction
);
// Xóa giao dịch
router.delete(
  "/:id",
  authMiddleware.verifyToken,
  transactionController.deleteTransaction
);
// Xử lý hình ảnh
router.post(
  "/image",
  authMiddleware.verifyToken,
  transactionController.upload.single("image"),
  transactionController.processImage
);

module.exports = router;