import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color successColor = Color(0xFF4CAF50); // Màu xanh lá (success)
  static const Color warningColor = Color(0xFFFFC107); // Màu vàng (warning)
  static const Color errorColor = Color(0xFFF44336); // Màu đỏ (error)
  static const Color infoColor = Color(0xFF2196F3); // Màu xanh dương nhạt (info)
  static const Color lightGreyColor = Color(0xFFEEEEEE); // Màu xám nhạt
  static const Color darkGreyColor = Color(0xFF9E9E9E); // Màu xám đậm

  static const Color primaryColor = Color(0xFF155E95); // Xanh dương đậm
  static const Color secondaryColor = Color(0xFF6A80B9); // Xanh dương nhạt
  static const Color accentColor = Color(0xFFF6C794); // Cam nhạt
  static const Color lightBackgroundColor = Color(0xFFECECF3); // Vàng nhạt - nền sáng
  static const Color darkBackgroundColor = Color(0xFF6A80B9); // Xanh dương nhạt - nền tối (nếu cần)
  static const Color textColor = Color(0xFF333333); // Màu chữ chính (đen)
  static const Color lightTextColor = Color(0xFFFFFFFF); // Màu chữ sáng (trắng)

  // Spacings
  static const double smallSpacing = 8.0;
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Paddings
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;

  // Font Sizes
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double extraLargeFontSize = 24.0;

  // BorderRadius
  static const double smallBorderRadius = 4.0;
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // App Name
  static const String appName = 'Smart Finance';

  // API Base URL
  //static const String apiBaseUrl = 'http://azserver.canhnguyen.online/api'; // Thay đổi khi deploy
  static const String apiBaseUrl = 'http://localhost:3000/api';

}
