const budgetService = require("../services/budget.service");

const getBudgets = async (req, res) => {
  try {
    const userId = req.userId;
    const budgets = await budgetService.getBudgetsByUserId(userId);
    res.status(200).json(budgets);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

const createBudget = async (req, res) => {
    try {
        const userId = req.userId;
        const { category_id, amount, period, start_date } = req.body;

        // Tạo budget mới
        const newBudget = await budgetService.createBudget({
            category_id,
            amount,
            period,
            start_date,
            user_id: userId,
        });

        res.status(201).json(newBudget);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

const getBudgetById = async (req, res) => { // Chỉ khai báo 1 lần
  try {
     const budgetId = req.params.id;
     const budget = await budgetService.getBudgetById(budgetId);
    if (!budget) {
      return res.status(404).json({ message: "Budget not found" });
    }
    res.status(200).json(budget);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};
const updateBudget = async (req, res) => {
    try {
        const userId = req.userId;
        const budgetId = req.params.id;
        const { category_id, amount, period, start_date } = req.body;
        
        console.log("Request Body:", req.body);
        
        // Kiểm tra xem budget có tồn tại và thuộc sở hữu của user không
        const existingBudget = await budgetService.getBudgetByIdAndUserId(budgetId, userId);
        if (!existingBudget) {
            return res.status(404).json({ message: 'Budget not found' });
        }

        // Cập nhật thông tin budget
        const updatedBudget = await budgetService.updateBudget(budgetId, {
            category_id,
            amount,
            period,
            start_date
        });

        res.status(200).json(updatedBudget);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

const deleteBudget = async (req, res) => {
    try {
        const userId = req.userId;
        const budgetId = req.params.id;

        // Kiểm tra xem budget có tồn tại và thuộc sở hữu của user không
        const existingBudget = await budgetService.getBudgetByIdAndUserId(budgetId, userId);
        if (!existingBudget) {
            return res.status(404).json({ message: 'Budget not found' });
        }

        // Xóa budget
        await budgetService.deleteBudget(budgetId);

        res.status(204).send(); // No content
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};



const getBudgetsByUserId = async (req, res) => {
  try {
    const userId = req.userId;
    const budgets = await budgetService.getBudgetsByUserId(userId);
    res.status(200).json(budgets);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

module.exports = {
  getBudgets,
  createBudget,
  getBudgetById,
  getBudgetsByUserId,
  updateBudget,
  deleteBudget,
};