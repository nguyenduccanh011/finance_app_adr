const express = require('express');
const authRouter = require('./auth.route');
const userRouter = require('./user.route');
const accountRouter = require('./account.route');
const categoryRouter = require('./category.route');
const transactionRouter = require('./transaction.route');
const budgetRouter = require('./budget.route');
const recurringTransactionRouter = require('./recurring_transaction.route'); // Thêm dòng này

const router = express.Router();

router.use('/auth', authRouter);
router.use('/users', userRouter);
router.use('/accounts', accountRouter);
router.use('/categories', categoryRouter);
router.use('/transactions', transactionRouter);
router.use('/budgets', budgetRouter);
router.use('/recurring-transactions', recurringTransactionRouter); // Thêm dòng này

module.exports = router;