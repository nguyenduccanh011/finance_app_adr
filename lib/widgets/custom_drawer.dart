import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_constants.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 60,
                  color: AppConstants.lightTextColor,
                ),
                const SizedBox(height: 4),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      authProvider.user?.username ?? 'Username',
                      style: const TextStyle(
                        color: AppConstants.lightTextColor,
                        fontSize: AppConstants.largeFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      authProvider.user?.email ?? 'Email',
                      style: const TextStyle(
                        color: AppConstants.lightTextColor,
                        fontSize: AppConstants.defaultFontSize,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Tổng quan'),
            onTap: () {
              Navigator.pop(context); // Đóng drawer
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Tài khoản'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/accounts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Ngân sách'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/budgets');
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart),
            title: const Text('Báo cáo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/reports');
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Giao dịch định kỳ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/recurring-transactions');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: const Text('Quản lý danh mục'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/categories-manager');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
            const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () {
              _confirmLogout(context);
            },
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }
}