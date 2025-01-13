import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget.dart';
import '../../utils/number_utils.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';

class BudgetDetailsScreen extends StatefulWidget {
  final Budget budget;

  const BudgetDetailsScreen({Key? key, required this.budget})
      : super(key: key);

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  // Thêm biến _budget để lưu trữ và cập nhật budget
  late Budget _budget;

  @override
  void initState() {
    super.initState();
    _budget = widget.budget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ngân sách'),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sử dụng _budget thay vì widget.budget
            Text('Danh mục: ${_budget.categoryName ?? 'N/A'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Số tiền: ${NumberUtils.formatCurrency(_budget.amount)}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Chu kỳ: ${_budget.period}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(_budget.startDate)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    // Sử dụng await và kiểm tra kết quả trả về
                    final updatedBudget = await Navigator.pushNamed(
                      context,
                      '/add-edit-budget',
                      arguments: _budget, // Truyền _budget
                    );
                    // Nếu AddEditBudgetScreen trả về true (đã sửa thành công)
                    if (updatedBudget == true) {
                      // Cập nhật lại _budget object
                      final newBudget = await Provider.of<BudgetProvider>(context, listen: false).getBudget(_budget.id);
                      setState(() {
                        _budget = newBudget!;
                      });
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, _budget.id);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Xóa'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int budgetId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa ngân sách?'),
        content: const Text('Bạn có chắc chắn muốn xóa ngân sách này?'),
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
              Provider.of<BudgetProvider>(context, listen: false)
                  .deleteBudget(budgetId)
                  .then((_) {
                Navigator.of(ctx).pop(); // Close the dialog
                Navigator.of(context)
                    .pop(); // Optionally close the details screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa ngân sách')),
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
