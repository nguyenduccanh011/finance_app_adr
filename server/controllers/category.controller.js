const categoryService = require("../services/category.service");

const getCategories = async (req, res) => {
  try {
    const userId = req.userId;
    const categories = await categoryService.getCategoriesByUserId(userId);
    res.status(200).json(categories);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

const createCategory = async (req, res) => {
    try {
        const userId = req.userId;
        const { name, type } = req.body;

        // Tạo category mới
        const newCategory = await categoryService.createCategory({
            user_id: userId,
            name,
            type,
        });

        res.status(201).json(newCategory);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

const getCategoryById = async (req, res) => {
  try {
    const userId = req.userId;
    const categoryId = req.params.id;
    const category = await categoryService.getCategoryByIdAndUserId(
      categoryId,
      userId
    );
    if (!category) {
      return res.status(404).json({ message: "Category not found" });
    }
    res.status(200).json(category);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

const updateCategory = async (req, res) => {
    try {
        const userId = req.userId;
        const categoryId = req.params.id;
        const { name, type } = req.body;

        // Kiểm tra xem category có tồn tại và thuộc sở hữu của user không
        const existingCategory = await categoryService.getCategoryByIdAndUserId(categoryId, userId);
        if (!existingCategory) {
            return res.status(404).json({ message: 'Category not found' });
        }

        // Cập nhật thông tin category
        const updatedCategory = await categoryService.updateCategory(categoryId, {
            name,
            type,
        });

        res.status(200).json(updatedCategory);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

const deleteCategory = async (req, res) => {
    try {
        const userId = req.userId;
        const categoryId = req.params.id;

        // Kiểm tra xem category có tồn tại và thuộc sở hữu của user không
        const existingCategory = await categoryService.getCategoryByIdAndUserId(categoryId, userId);
        if (!existingCategory) {
            return res.status(404).json({ message: 'Category not found' });
        }

        // Xóa category
        await categoryService.deleteCategory(categoryId);

        res.status(204).send(); // No content
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};

module.exports = {
  getCategories,
  createCategory,
  getCategoryById,
  updateCategory,
  deleteCategory,
};