import 'package:flutter/material.dart';
import '../models/category.dart' as model;

class CategoryListItem extends StatelessWidget {
  final model.Category category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryListItem({
    Key? key,
    required this.category,
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
      leading: Icon(
        getCategoryIcon(category.name), // Sử dụng hàm getCategoryIcon
        color: category.type == 'income' ? Colors.green : Colors.red,
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
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