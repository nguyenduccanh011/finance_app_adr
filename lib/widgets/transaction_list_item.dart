import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/number_utils.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionListItem(
      {Key? key, required this.transaction, required this.onTap})
      : super(key: key);

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
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: transaction.amount < 0 ? Colors.red : Colors.green,
        child: Icon(
          getCategoryIcon(transaction.categoryName), // Sử dụng hàm getCategoryIcon
          color: Colors.white,
        ),
      ),
      title: Text(
        transaction.categoryName ?? 'N/A',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        DateFormat('dd/MM/yyyy').format(transaction.transactionDate),
      ),
      trailing: Text(
        NumberUtils.formatCurrency(transaction.amount),
        style: TextStyle(
          color: transaction.amount < 0 ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}