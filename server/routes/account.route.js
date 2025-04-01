const express = require("express");
const router = express.Router();
const accountController = require("../controllers/account.controller");
const authMiddleware = require("../middleware/auth.middleware");

// Lấy danh sách tài khoản
router.get(
  "/",
  authMiddleware.verifyToken,
  accountController.getAccounts
);
// Tạo tài khoản mới
router.post(
  "/",
  authMiddleware.verifyToken,
  accountController.createAccount
);
// Lấy thông tin chi tiết tài khoản
router.get(
  "/:id",
  authMiddleware.verifyToken,
  accountController.getAccountById
);
// Cập nhật thông tin tài khoản
router.put(
  "/:id",
  authMiddleware.verifyToken,
  accountController.updateAccount
);
// Xóa tài khoản
router.delete(
  "/:id",
  authMiddleware.verifyToken,
  accountController.deleteAccount
);

module.exports = router;