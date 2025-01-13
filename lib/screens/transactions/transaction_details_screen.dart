import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../utils/number_utils.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  IconData getCategoryIcon(String? categoryName) {
    switch (categoryName) {
      case 'Ăn uống':
        return Icons.fastfood;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Nhà ở':
        return Icons.home;
      case 'Điện nước':
        return Icons.electrical_services;
      case 'Mua sắm':
        return Icons.shopping_cart;
      case 'Giải trí':
        return Icons.sports_esports;
      case 'Du lịch':
        return Icons.flight;
      case 'Lương':
        return Icons.attach_money;
      case 'Thưởng':
        return Icons.redeem;
      case 'Lãi suất':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị icon danh mục ở đây
            Row(
              children: [
                Icon(getCategoryIcon(widget.transaction.categoryName), size: 24, color: AppConstants.primaryColor,),
                const SizedBox(width: 8),
                Text('Danh mục: ${widget.transaction.categoryName ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tài khoản: ${widget.transaction.accountName ?? 'N/A'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
                'Số tiền: ${NumberUtils.formatCurrency(widget.transaction.amount)}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
                'Mô tả: ${widget.transaction.description ?? 'Không có mô tả'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Ngày: ${DateFormat('dd/MM/yyyy').format(widget.transaction.transactionDate)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit-transaction',
                      arguments: widget.transaction.id,
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                        context, widget.transaction.id);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Xóa'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
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
              Provider.of<TransactionProvider>(context, listen: false)
                  .deleteTransaction(transactionId)
                  .then((_) {
                Navigator.of(ctx).pop(); // Close the dialog
                Navigator.of(context)
                    .pop(); // Optionally close the details screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa giao dịch')),
                );
              }).catchError((error) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa thất bại: $error')),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}