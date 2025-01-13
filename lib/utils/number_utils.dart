import 'package:intl/intl.dart';

class NumberUtils {
  static final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  // Format số tiền sang định dạng tiền tệ (có dấu phân cách hàng nghìn, đơn vị VND)
  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  // Chuyển String sang double (có xử lý ngoại lệ)
  static double? parseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }

  // Chuyển String sang int (có xử lý ngoại lệ)
  static int? parseInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }
}
