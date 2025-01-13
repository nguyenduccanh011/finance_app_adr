import 'package:intl/intl.dart';

class DateTimeUtils {
  static final DateFormat _serverDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _displayDateTimeFormat =
      DateFormat('dd/MM/yyyy HH:mm');

  // Chuyển từ DateTime sang String để gửi lên server (yyyy-MM-dd)
  static String formatDateForServer(DateTime dateTime) {
    return _serverDateFormat.format(dateTime);
  }

  // Chuyển từ String từ server (yyyy-MM-dd) sang DateTime
  static DateTime parseDateFromServer(String dateString) {
    return _serverDateFormat.parse(dateString);
  }

  // Format DateTime để hiển thị (dd/MM/yyyy)
  static String formatDateForDisplay(DateTime dateTime) {
    return _displayDateFormat.format(dateTime);
  }

  // Format DateTime để hiển thị kèm giờ (dd/MM/yyyy HH:mm)
  static String formatDateTimeForDisplay(DateTime dateTime) {
    return _displayDateTimeFormat.format(dateTime);
  }

  // Lấy ngày đầu tiên của tháng
  static DateTime getFirstDayOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  // Lấy ngày cuối cùng của tháng
  static DateTime getLastDayOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0);
  }
}
