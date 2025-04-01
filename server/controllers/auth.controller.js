// TODO: Implement authentication logic (register, login)
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userService = require('../services/user.service');
const accountService = require('../services/account.service');
const categoryService = require('../services/category.service');
const db = require('../config/database');

const register = async (req, res) => {

    console.log("Request Body:", req.body); // Phải ở đầu hàm

    // Lấy thông tin user từ req.body
    const { username, password, email } = req.body;


    try {
        // Kiểm tra xem username hoặc email đã tồn tại chưa
        const existingUser = await userService.findUserByUsernameOrEmail(username, email);
        if (existingUser) {
            return res.status(400).json({ message: 'Username hoặc email đã tồn tại' });
        }

        // Thêm console.log ở đây
        console.log("Password:", password, "Type:", typeof password);


        // Hash mật khẩu
        const hashedPassword = await bcrypt.hash(password, 10);

        // Tạo user mới
        const newUser = await userService.createUser({
            username,
            password: hashedPassword,
            email,
        });

        // Tạo tài khoản mặc định "Tiền mặt"
        await accountService.createAccount({
            user_id: newUser.id, // Lấy ID của user vừa tạo
            name: 'Tiền mặt',
            balance: 0, // Hoặc số dư mặc định khác
        });
        
        // Tạo các category mặc định
        await categoryService.createDefaultCategoriesForUser(newUser.id);

        // Trả về thông tin user (không bao gồm mật khẩu)
        res.status(201).json({
            id: newUser.id,
            username: newUser.username,
            email: newUser.email,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Lỗi server' });
    }
};
const login = async (req, res) => {
  // Lấy thông tin user từ req.body
  const { username, password } = req.body;

  try {
      // Tìm user theo username
      const user = await userService.findUserByUsername(username);
      if (!user) {
          return res.status(401).json({ message: 'Sai tên đăng nhập hoặc mật khẩu' });
      }

      // So sánh mật khẩu
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
          return res.status(401).json({ message: 'Sai tên đăng nhập hoặc mật khẩu' });
      }

      // Tạo JWT token
      const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });

      // Trả về token và thông tin user
      res.status(200).json({
          token,
          user: {
              id: user.id,
              username: user.username,
              email: user.email,
          },
      });
  } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Lỗi server' });
  }
};

module.exports = {
  register,
  login
};