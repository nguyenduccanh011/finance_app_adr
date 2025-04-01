const transactionService = require('../services/transaction.service');
const imageService = require('../services/image.service');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' }); // Cấu hình multer để lưu file tạm thời

const getTransactions = async (req, res) => {
  try {
    const userId = req.userId;
    // Lấy các tham số từ query string (nếu có)
    const { accountId, categoryId, startDate, endDate } = req.query;

    const transactions = await transactionService.getTransactionsByUserId(
      userId,
      accountId,
      categoryId,
      startDate,
      endDate
    );
    res.status(200).json(transactions);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

const createTransaction = async (req, res) => {
  try {
    const userId = req.userId;
    const { account_id, category_id, amount, description, transaction_date } =
      req.body;
      
    console.log("Received transaction_date:", transaction_date);
    // Tạo transaction mới
    const newTransaction = await transactionService.createTransaction({
      account_id,
      category_id,
      amount,
      description,
      transaction_date,
      //user_id: userId,
    });

    res.status(201).json(newTransaction);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};
 
const getTransactionById = async (req, res) => {
  try {
    const userId = req.userId;
    const transactionId = req.params.id;
    const transaction = await transactionService.getTransactionByIdAndUserId(
      transactionId,
      userId
    );
    if (!transaction) {
      return res.status(404).json({ message: "Transaction not found" });
    }
    res.status(200).json(transaction);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

const updateTransaction = async (req, res) => {
    try {
        const userId = req.userId;
        const transactionId = req.params.id;
        const { account_id, category_id, amount, description, transaction_date } = req.body;

        // Kiểm tra xem transaction có tồn tại và thuộc sở hữu của user không
        const existingTransaction = await transactionService.getTransactionByIdAndUserId(transactionId, userId);
        if (!existingTransaction) {
            return res.status(404).json({ message: 'Transaction not found' });
        }

        // Cập nhật thông tin transaction
        const updatedTransaction = await transactionService.updateTransaction(transactionId, {
            account_id,
            category_id,
            amount,
            description,
            transaction_date
        });

        res.status(200).json(updatedTransaction);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

const deleteTransaction = async (req, res) => {
    try {
        const userId = req.userId;
        const transactionId = req.params.id;

        // Kiểm tra xem transaction có tồn tại và thuộc sở hữu của user không
        const existingTransaction = await transactionService.getTransactionByIdAndUserId(transactionId, userId);
        if (!existingTransaction) {
            return res.status(404).json({ message: 'Transaction not found' });
        }

        // Xóa transaction
        await transactionService.deleteTransaction(transactionId);

        res.status(204).send(); // No content
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

// API xử lý hình ảnh hóa đơn
const processImage =  async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'No image uploaded' });
    }

    try {
        const imageBuffer = req.file.buffer;
        const imageData = await imageService.processImageWithOpenAI(imageBuffer);
        
        if (!imageData || !imageData.amount) {
          return res.status(500).json({ message: "Không thể xử lý thông tin từ hình ảnh" });
        }

        const transactionData = {
          amount: parseFloat(imageData.amount),
          description: imageData.description || "",
          transaction_date: imageData.date || new Date().toISOString().slice(0, 10),
        };
    
        res.status(200).json(transactionData);
    } catch (error) {
        console.error('Lỗi xử lý hình ảnh:', error);
        res.status(500).json({ message: 'Lỗi xử lý hình ảnh' });
    }
};

module.exports = {
  getTransactions,
  createTransaction,
  getTransactionById,
  updateTransaction,
  deleteTransaction,
  processImage,
  upload
};