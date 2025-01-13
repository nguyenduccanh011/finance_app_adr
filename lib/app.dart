import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'utils/app_constants.dart';
import 'providers/auth_provider.dart';
import '../main.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Thêm dòng này
      title: AppConstants.appName,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor, // Thêm dòng này
        //primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          titleTextStyle: TextStyle(
            color: AppConstants.lightTextColor,
            fontSize: AppConstants.largeFontSize,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppConstants.lightTextColor), // Màu icon
        ),
        scaffoldBackgroundColor: AppConstants.lightBackgroundColor, // Thêm màu nền
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppConstants.textColor),
          bodyMedium: TextStyle(color: AppConstants.textColor),
          // ... các style khác cho text
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.lightTextColor,
          ),
        ),

      ),
      debugShowCheckedModeBanner: false,
      initialRoute: context.read<AuthProvider>().isAuthenticated // Sửa thành read
          ? Routes.home
          : Routes.login,
      routes: Routes.routes,
    );
  }
}