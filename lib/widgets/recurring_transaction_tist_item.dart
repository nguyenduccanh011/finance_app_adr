import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../utils/number_utils.dart';

class RecurringTransactionListItem extends StatelessWidget {
  final RecurringTransaction recurringTransaction;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecurringTransactionListItem({
    Key? key,
    required this.recurringTransaction,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

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
        backgroundColor: recurringTransaction.type == 'income'
            ? Colors.green
            : Colors.red,
        child: Icon(
          getCategoryIcon(recurringTransaction.categoryName),
          color: Colors.white,
        ),
      ),
      title: Text(
        recurringTransaction.categoryName ?? 'N/A',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${recurringTransaction.frequency} (Interval: ${recurringTransaction.interval}) - Next: ${DateFormat('dd/MM/yyyy').format(recurringTransaction.nextOccurrence)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}