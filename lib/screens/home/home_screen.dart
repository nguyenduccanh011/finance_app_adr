// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Hoặc thư viện chart khác
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../utils/number_utils.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final accountProvider = context.read<AccountProvider>();

    try {
      if (accountProvider.accounts.isEmpty) {
        await accountProvider.fetchAccounts();
      }
    } catch (error) {
      print('Failed to load data: $error');
      _showErrorDialog(error.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
      ),
      drawer: const CustomDrawer(), // Thêm drawer vào đây
      body: Consumer2<AccountProvider, TransactionProvider>(
        builder: (context, accountProvider, transactionProvider, child) {
          if (accountProvider.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final totalBalance = accountProvider.totalBalance;
          final transactions = transactionProvider.transactions;

          final currentMonthTransactions = transactions.where((transaction) {
            final now = DateTime.now();
            return transaction.transactionDate.month == now.month &&
                transaction.transactionDate.year == now.year;
          }).toList();

          double totalIncome = 0;
          double totalExpense = 0;
          for (final transaction in currentMonthTransactions) {
            if (transaction.amount > 0) {
              totalIncome += transaction.amount;
            } else {
              totalExpense += transaction.amount;
            }
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTotalBalanceCard(totalBalance),
                  _buildChartCard(totalIncome, totalExpense),
                  _buildRecentTransactionsCard(transactions),
                  _buildQuickActions(context),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildTotalBalanceCard(double totalBalance) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng số dư',
                    style: TextStyle(
                      fontSize: AppConstants.largeFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Màu chữ tiêu đề
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing),
                  Text(
                    NumberUtils.formatCurrency(totalBalance),
                    style: const TextStyle(
                      fontSize: AppConstants.extraLargeFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Màu chữ chính
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/images/coins.png', // Đường dẫn đến hình minh họa
              height: 80, // Kích thước hình
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(double totalIncome, double totalExpense) {
    // Tính tổng thu nhập và chi tiêu
    double total = totalIncome + totalExpense.abs();
    total = total == 0
        ? 1
        : total; // Tránh chia cho 0 bằng cách gán tổng là 1 nếu cả thu và chi đều là 0

    double incomePercentage = (totalIncome / total) * 100;
    double expensePercentage = (totalExpense.abs() / total) * 100;

    return Card(
      elevation: 4, // Thêm đổ bóng
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Text('Thu Chi Tháng Này',
                style: TextStyle(
                  fontSize: AppConstants.largeFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor, // Màu chữ tiêu đề
                )),
            const SizedBox(height: AppConstants.defaultSpacing),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green, // Giữ nguyên màu xanh cho "Thu"
                      value: totalIncome > 0 ? totalIncome : 0.001,
                      title: totalIncome > 0
                          ? '${incomePercentage.toStringAsFixed(0)}%'
                          : '',
                      radius: 50,
                      titleStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: totalIncome > 0
                              ? AppConstants.lightTextColor
                              : Colors
                              .transparent), // Màu chữ trắng, nếu giá trị bằng 0 thì không hiện
                    ),
                    PieChartSectionData(
                      color: const Color.fromARGB(
                          255, 179, 35, 25), // Giữ nguyên màu đỏ cho "Chi"
                      value:
                      totalExpense.abs() > 0 ? totalExpense.abs() : 0.001,
                      title: totalExpense.abs() > 0
                          ? '${expensePercentage.toStringAsFixed(0)}%'
                          : '',
                      radius: 50,
                      titleStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: totalExpense.abs() > 0
                              ? AppConstants.lightTextColor
                              : Colors.transparent),
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2, // Khoảng cách giữa các phần
                ),
              ),
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Giữ nguyên màu của chú thích
                _buildLegendItem(Colors.green, 'Thu', totalIncome),
                _buildLegendItem(Colors.red, 'Chi', totalExpense),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String title, double amount) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: AppConstants.smallSpacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(NumberUtils.formatCurrency(amount),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsCard(List<Transaction> transactions) {
    return Card(
      elevation: 4, // Thêm đổ bóng
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chi tiêu gần đây',
                style: TextStyle(
                  fontSize: AppConstants.largeFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor, // Màu chữ tiêu đề
                )),
            const SizedBox(height: AppConstants.defaultSpacing),
            if (transactions.isEmpty)
              const Text('Không có giao dịch nào.')
            else
              ...transactions.take(5).map((transaction) => ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                  transaction.amount < 0 ? Colors.red : Colors.green,
                  child: Icon(
                    getCategoryIcon(transaction.categoryName), // Sử dụng hàm getCategoryIcon
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  transaction.categoryName ?? 'N/A',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor),
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(transaction.transactionDate),
                  style: const TextStyle(
                      color: AppConstants.darkGreyColor), // Màu chữ phụ
                ),
                trailing: Text(
                  NumberUtils.formatCurrency(transaction.amount),
                  style: TextStyle(
                    color:
                    transaction.amount < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/transaction-details',
                    arguments: transaction,
                  );
                },
              )),
          ],
        ),
      ),
    );
  }

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

// nút thêm giao dịch
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        // Thay Row bằng Column
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-transaction');
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm GD'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: AppConstants.lightTextColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultPadding,
                  horizontal: AppConstants.largePadding),
              minimumSize: const Size(double.infinity, 0), // Thêm dòng này
            ),
          ),
          const SizedBox(
              height:
              AppConstants.defaultSpacing), // Thêm khoảng cách giữa hai nút
        ],
      ),
    );
  }
}
