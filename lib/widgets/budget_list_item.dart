import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../utils/number_utils.dart';
import '../utils/app_constants.dart';
import '../providers/transaction_provider.dart';

class BudgetListItem extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetListItem({
    Key? key,
    required this.budget,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  IconData getCategoryIcon(String? categoryName) {
    switch (categoryName) {
      case 'Ăn uống':
        return Icons.fastfood;
      case 'Di chuyển':
        return Icons.directions_car; // Hoặc Icons.commute
      case 'Nhà ở':
        return Icons.home;
      case 'Điện nước':
        return Icons.electrical_services; // Hoặc Icons.water
      case 'Mua sắm':
        return Icons.shopping_cart;
      case 'Giải trí':
        return Icons.sports_esports; // Hoặc Icons.movie, Icons.music_note
      case 'Du lịch':
        return Icons.flight; // Hoặc Icons.beach_access, Icons.map
      case 'Lương':
        return Icons.attach_money;
      case 'Thưởng':
        return Icons.redeem; // Hoặc Icons.celebration
      case 'Lãi suất':
        return Icons.trending_up; // Hoặc Icons.savings
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider =
    Provider.of<TransactionProvider>(context, listen: false);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            getCategoryIcon(budget.categoryName),
            size: 30,
            color: AppConstants.primaryColor,
          ),
          title: Text(
            budget.categoryName ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              FutureBuilder<double>(
                future: transactionProvider.getTotalSpentForCategory(
                    budget.categoryId),
                builder: (context, snapshot) {
                  double totalSpent = snapshot.data ?? 0.0;
                  double remainingBudget = budget.amount - totalSpent;
                  double progressPercentage =
                      totalSpent / budget.amount;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progressPercentage,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressPercentage > 0.8
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Còn lại ${NumberUtils.formatCurrency(remainingBudget)}',
                            style: TextStyle(
                                color: remainingBudget > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          Text('Hôm nay',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (String item) {
              switch (item) {
                case 'edit':
                  onEdit();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Sửa'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Xóa'),
                ),
              ];
            },
          ),
        ),
      ),
    );
  }
}