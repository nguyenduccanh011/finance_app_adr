// TODO: Implement account-related logic
const accountService = require("../services/account.service");

const getAccounts = async (req, res) => {
  try {
    const userId = req.userId; // Lấy userId từ middleware xác thực
    const accounts = await accountService.getAccountsByUserId(userId);
    res.status(200).json(accounts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

const createAccount = async (req, res) => {
    try {
        const userId = req.userId;
        const { name, balance } = req.body;

        // Tạo account mới
        const newAccount = await accountService.createAccount({
            user_id: userId,
            name,
            balance,
        });

        res.status(201).json(newAccount);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

const getAccountById = async (req, res) => {
  try {
    const userId = req.userId;
    const accountId = req.params.id;
    const account = await accountService.getAccountByIdAndUserId(
      accountId,
      userId
    );
    if (!account) {
      return res.status(404).json({ message: "Account not found" });
    }
    res.status(200).json(account);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

const updateAccount = async (req, res) => {
    try {
        const userId = req.userId;
        const accountId = req.params.id;
        const { name, balance } = req.body;

        // Kiểm tra xem account có tồn tại và thuộc sở hữu của user không
        const existingAccount = await accountService.getAccountByIdAndUserId(accountId, userId);
        if (!existingAccount) {
            return res.status(404).json({ message: 'Account not found' });
        }

        // Cập nhật thông tin account
        const updatedAccount = await accountService.updateAccount(accountId, {
            name,
            balance,
        });

        res.status(200).json(updatedAccount);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

const deleteAccount = async (req, res) => {
    try {
        const userId = req.userId;
        const accountId = req.params.id;

        // Kiểm tra xem account có tồn tại và thuộc sở hữu của user không
        const existingAccount = await accountService.getAccountByIdAndUserId(accountId, userId);
        if (!existingAccount) {
            return res.status(404).json({ message: 'Account not found' });
        }

        // Xóa account
        await accountService.deleteAccount(accountId);

        res.status(204).send(); // No content
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

module.exports = {
  getAccounts,
  createAccount,
  getAccountById,
  updateAccount,
  deleteAccount,
};