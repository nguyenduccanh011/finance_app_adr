const recurringTransactionService = require('../services/recurring_transaction.service');

const getRecurringTransactions = async (req, res) => {
  try {
    const userId = req.userId;
    const recurringTransactions =
      await recurringTransactionService.getRecurringTransactionsByUserId(
        userId
      );
    res.status(200).json(recurringTransactions);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

const createRecurringTransaction = async (req, res) => {
  try {
      const userId = req.userId;
      const { account_id, category_id, amount, description, type, frequency, interval, start_date, end_date } = req.body;
      const newRecurringTransaction = await recurringTransactionService.createRecurringTransaction({
          user_id: userId,
          account_id,
          category_id,
          amount,
          description,
          type,
          frequency,
          interval,
          start_date,
          end_date,
      });
      // Kiểm tra giá trị trả về từ service
      console.log("Recurring transaction created:", newRecurringTransaction);

      res.status(201).json(newRecurringTransaction);
  } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Lỗi server' });
  }
};

const getRecurringTransactionById = async (req, res) => {
  try {
    const userId = req.userId;
    const recurringTransactionId = req.params.id;
    const recurringTransaction =
      await recurringTransactionService.getRecurringTransactionById(
        recurringTransactionId
      );

    if (!recurringTransaction) {
      return res
        .status(404)
        .json({ message: 'Recurring Transaction not found' });
    }

    // Kiểm tra xem recurringTransaction có thuộc về userId đang đăng nhập không
    if (recurringTransaction.user_id !== userId) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    res.status(200).json(recurringTransaction);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

const updateRecurringTransaction = async (req, res) => {
  try {
    const userId = req.userId;
    const recurringTransactionId = req.params.id;
    const {
      account_id,
      category_id,
      amount,
      description,
      type,
      frequency,
      interval,
      start_date,
      end_date,
    } = req.body;

    const existingRecurringTransaction =
      await recurringTransactionService.getRecurringTransactionById(
        recurringTransactionId
      );

    if (!existingRecurringTransaction) {
      return res
        .status(404)
        .json({ message: 'Recurring Transaction not found' });
    }
    // Kiểm tra xem recurringTransaction có thuộc về userId đang đăng nhập không
    if (existingRecurringTransaction.user_id !== userId) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    const updatedRecurringTransaction =
      await recurringTransactionService.updateRecurringTransaction(
        recurringTransactionId,
        {
          account_id,
          category_id,
          amount,
          description,
          type,
          frequency,
          interval,
          start_date,
          end_date,
        }
      );
    res.status(200).json(updatedRecurringTransaction);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

const deleteRecurringTransaction = async (req, res) => {
  try {
    const userId = req.userId;
    const recurringTransactionId = req.params.id;

    const existingRecurringTransaction = await recurringTransactionService.getRecurringTransactionById(recurringTransactionId);

    if (!existingRecurringTransaction) {
      return res.status(404).json({ message: 'Recurring Transaction not found' });
    }

    if (existingRecurringTransaction.user_id !== userId) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    await recurringTransactionService.deleteRecurringTransaction(
      recurringTransactionId
    );
    res.status(204).send();
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

module.exports = {
  getRecurringTransactions,
  createRecurringTransaction,
  getRecurringTransactionById,
  updateRecurringTransaction,
  deleteRecurringTransaction,
};