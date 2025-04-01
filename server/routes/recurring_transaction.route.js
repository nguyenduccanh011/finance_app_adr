const express = require('express');
const router = express.Router();
const recurringTransactionController = require('../controllers/recurring_transaction.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Lấy danh sách giao dịch định kỳ của user hiện tại
router.get('/', authMiddleware.verifyToken, recurringTransactionController.getRecurringTransactions);

// Tạo mới giao dịch định kỳ
router.post('/', authMiddleware.verifyToken, recurringTransactionController.createRecurringTransaction);

// Lấy thông tin chi tiết của giao dịch định kỳ
router.get('/:id', authMiddleware.verifyToken, recurringTransactionController.getRecurringTransactionById);

// Cập nhật giao dịch định kỳ
router.put('/:id', authMiddleware.verifyToken, recurringTransactionController.updateRecurringTransaction);

// Xóa giao dịch định kỳ
router.delete('/:id', authMiddleware.verifyToken, recurringTransactionController.deleteRecurringTransaction);

module.exports = router;