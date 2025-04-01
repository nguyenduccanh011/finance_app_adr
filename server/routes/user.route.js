const express = require("express");
const router = express.Router();
const userController = require("../controllers/user.controller");
const authMiddleware = require("../middleware/auth.middleware");

// Lấy thông tin user hiện tại
router.get("/me", authMiddleware.verifyToken, userController.getCurrentUser);
// cập nhật thông tin user
router.put("/me", authMiddleware.verifyToken, userController.updateCurrentUser);

module.exports = router;