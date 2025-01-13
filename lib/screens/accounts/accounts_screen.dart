import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../routes.dart';
import '../../utils/number_utils.dart';
import '../../widgets/account_list_item.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    await Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        // Thêm actions vào AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Handle notification
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Handle user profile
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Tổng cộng
          Container(
            decoration: BoxDecoration(
              color: Colors.greenAccent, // Màu nền xanh lá
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Tổng cộng:",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                Consumer<AccountProvider>(
                  builder: (context, accountProvider, child) {
                    return Text(
                      NumberUtils.formatCurrency(
                          accountProvider.totalBalance),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Hai nút chức năng
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transfer-history');
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("Lịch sử chuyển khoản"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppConstants.lightTextColor, backgroundColor: AppConstants.primaryColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transfer');
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text("Giao dịch chuyển khoản mới"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppConstants.lightTextColor, backgroundColor: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Danh sách tài khoản
          Expanded(
            child: Consumer<AccountProvider>(
              builder: (context, accountProvider, child) {
                if (accountProvider.accounts.isEmpty) {
                  return const Center(child: Text("Không có tài khoản nào."));
                }
                return RefreshIndicator(
                  onRefresh: _loadAccounts,
                  child: ListView.builder(
                    itemCount: accountProvider.accounts.length,
                    itemBuilder: (context, index) {
                      final account = accountProvider.accounts[index];
                      return AccountListItem(
                        account: account,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/account-details',
                            arguments: account,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-edit-account');
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int accountId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản này?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Không'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Có'),
            onPressed: () {
              Provider.of<AccountProvider>(context, listen: false)
              .deleteAccount(accountId)
              .then((_) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa tài khoản')),
                );
              })
              .catchError((error) {
                Navigator.of(ctx).pop();
                // Hiển thị thông báo lỗi cụ thể
                String errorMessage = 'Xóa thất bại.';
                if (error.toString().contains('Không thể xóa tài khoản cuối cùng.')) {
                  errorMessage = 'Không thể xóa tài khoản cuối cùng.';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
