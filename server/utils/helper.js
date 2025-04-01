// Bạn có thể thêm các hàm tiện ích vào đây, ví dụ:

const formatDate = (date) => {
    return date.toISOString().slice(0, 10); // YYYY-MM-DD
  };
  
  const formatCurrency = (amount) => {
    return amount.toLocaleString('vi-VN', { style: 'currency', currency: 'VND' });
  };
  
  module.exports = {
    formatDate,
    formatCurrency,
  };