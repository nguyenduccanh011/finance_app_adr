import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesst_app/widgets/custom_bottom_navigation_bar.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes.dart';
import '../../widgets/budget_header.dart';
import '../../widgets/budget_list_item.dart';
import '../../utils/app_constants.dart';
import '../../widgets/budget_progress_indicator.dart';
import '../../widgets/custom_drawer.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  _BudgetsScreenState createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  bool _isInit = true; // Thêm biến này

  @override
   void didChangeDependencies() {
      super.didChangeDependencies();
      if (_isInit) {
       _loadBudgets();
       _isInit = false; // Đảm bảo chỉ chạy một lần
      }
  }

  @override
  void initState() {
    super.initState();
    print('fetchBudgets called from ${StackTrace.current}');
  }

  Future<void> _loadBudgets() async {
    print('fetchBudgets called from ${StackTrace.current}');
    try {
      await Provider.of<BudgetProvider>(context, listen: false).fetchBudgets();
      await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách'),
      ),
      drawer: const CustomDrawer(),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          return RefreshIndicator(
            onRefresh: _loadBudgets,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BudgetHeader(),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    Consumer<BudgetProvider>(
                      builder: (context, budgetProvider, child) {
                        final totalBudget = budgetProvider.budgets.fold<double>(
                          0,
                              (sum, budget) => sum + budget.amount,
                        );

                        final transactions = Provider.of<TransactionProvider>(context).transactions;
                        final totalSpent = transactions.where((transaction) => transaction.amount < 0)
                            .fold<double>(
                          0,
                              (sum, transaction) => sum + transaction.amount.abs(),
                        );

                        final remainingDays = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).difference(DateTime.now()).inDays;

                        return BudgetProgressIndicator(
                          totalBudget: totalBudget,
                          totalSpent: totalSpent,
                          remainingDays: remainingDays,
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    // Di chuyển ElevatedButton ra ngoài Consumer
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.addBudget).then((value) {
                          if (value == true) {
                            _loadBudgets();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                            horizontal: AppConstants.largePadding),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: const Text('Tạo Ngân sách',
                          style: TextStyle(color: AppConstants.lightTextColor)),
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    // Kiểm tra budgetProvider.budgets.isEmpty ở đây
                    if (budgetProvider.budgets.isEmpty)
                      const Center(child: Text('Không có ngân sách nào.'))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: budgetProvider.budgets.length,
                        itemBuilder: (context, index) {
                          final budget = budgetProvider.budgets[index];
                          return BudgetListItem(
                            budget: budget,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.budgetDetails,
                                arguments: budget,
                              );
                            },
                            onEdit: () {
                              Navigator.pushNamed(
                                context,
                                Routes.addBudget,
                                arguments: budget,
                              ).then((value) {
                                if (value == true) {
                                  _loadBudgets();
                                }
                              });
                            },
                            onDelete: () {
                              _showDeleteConfirmationDialog(context, budget.id);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
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
                Navigator.of(ctx).pop();
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
