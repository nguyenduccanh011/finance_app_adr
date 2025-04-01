// TODO: Implement user-related logic (get user info, update user info)
const userService = require('../services/user.service');

const getCurrentUser = async (req, res) => {
  try {
      const userId = req.userId; // Lấy userId từ middleware xác thực

      const user = await userService.findUserById(userId);
      if (!user) {
          return res.status(404).json({ message: 'User not found' });
      }

      // Trả về thông tin user (không bao gồm mật khẩu)
      res.status(200).json({
          id: user.id,
          username: user.username,
          email: user.email,
      });
  } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Lỗi server' });
  }
};

const updateCurrentUser = async (req, res) => {
  // TODO: Implement logic to update user information
  try {
    const userId = req.userId; // Lấy userId từ middleware xác thực
    const { username, email } = req.body; // Lấy thông tin cần update từ req.body

    // Kiểm tra xem username hoặc email mới đã tồn tại chưa (nếu có thay đổi)
    if (username || email) {
      const existingUser = await userService.findUserByUsernameOrEmail(
        username || "",
        email || ""
      );
      if (
        existingUser &&
        existingUser.id !== userId
      ) {
        return res
          .status(400)
          .json({ message: "Username hoặc email đã tồn tại" });
      }
    }

    // Cập nhật thông tin user
    const updatedUser = await userService.updateUser(userId, {
      username,
      email,
    });

    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }

    // Trả về thông tin user sau khi cập nhật
    res.status(200).json({
      id: updatedUser.id,
      username: updatedUser.username,
      email: updatedUser.email,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi server" });
  }
};

module.exports = {
  getCurrentUser,
  updateCurrentUser
};