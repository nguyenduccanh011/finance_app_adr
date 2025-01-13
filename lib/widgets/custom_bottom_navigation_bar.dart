import 'package:flutter/material.dart';
import '../routes.dart';
import '../utils/app_constants.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // Xử lý chuyển màn hình khi nhấn vào các item
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/');
            break;
          case 1:
            //Navigator.pushReplacementNamed(context, '/accounts');
            Navigator.pushReplacementNamed(context, Routes.transactions);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/budgets');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/reports');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Tổng quan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: 'Sổ giao dịch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Ngân sách',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart),
          label: 'Báo cáo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: AppConstants.darkGreyColor, // Thay vì màu grey chung chung
      selectedFontSize: 12,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      backgroundColor: AppConstants.lightBackgroundColor, // Thêm màu nền
    );
  }
}
