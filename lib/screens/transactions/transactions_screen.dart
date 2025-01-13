import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../utils/app_constants.dart';
import '../../utils/number_utils.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import 'package:collection/collection.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isLoading = false;
  Account? _selectedAccount; // Thêm biến này
  String _selectedPeriod = 'THÁNG NÀY';

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _dataLoaded = false;


  @override
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _loadTransactions().then((_) {
        setState(() {
          _dataLoaded = true; // Đánh dấu là dữ liệu đã được load
        });
      });
    }
  }



  Future<void> _loadTransactions() async {
    if (!mounted) return;
    final transactionProvider =
    Provider.of<TransactionProvider>(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
      });
      // Tính toán lại _startDate và _endDate trước khi gọi fetchTransactions
      _getStartAndEndDate();
      await transactionProvider.fetchTransactions(
        accountId: _selectedAccount?.id,
        startDate: _startDate.toIso8601String().split('T')[0],
        endDate: _endDate.toIso8601String().split('T')[0],
      );
    } catch (error) {
      print('Lỗi khi tải giao dịch: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải giao dịch: ${error.toString()}')),
      );
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _getStartAndEndDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'THÁNG TRƯỚC':
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 0);
        break;
      case 'THÁNG NÀY':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'TƯƠNG LAI':
        _startDate = DateTime(now.year, now.month + 1, 1);
        _endDate = DateTime(now.year + 10, now.month, 0); // Ví dụ: 10 năm sau
        break;
    }
  }

  // Thêm hàm này vào trong class _TransactionsScreenState
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


  DateTime _getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Số giao dịch"),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        // Sử dụng Column để chứa các phần tử
        children: [
          // Account Selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<AccountProvider>(
              builder: (context, accountProvider, child) {
                final accounts = accountProvider.accounts;
                // Set giá trị mặc định cho _selectedAccount nếu danh sách accounts không rỗng
                if (_selectedAccount == null && accounts.isNotEmpty) {
                  _selectedAccount = accounts[0];
                }
                return DropdownButtonFormField<Account>(
                  decoration: const InputDecoration(
                    labelText: 'Tài khoản',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedAccount,
                  onChanged: (Account? newValue) {
                    setState(() {
                      _selectedAccount = newValue;
                      _loadTransactions(); // Load lại danh sách giao dịch
                    });
                  },
                  items:
                      accounts.map<DropdownMenuItem<Account>>((Account account) {
                    return DropdownMenuItem<Account>(
                      value: account,
                      child: Text(account.name),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Hiển thị số dư
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Consumer<AccountProvider>(
                      builder: (context, accountProvider, child) {
                    final selectedAccount = accountProvider.accounts
                        .firstWhereOrNull(
                            (element) => element.id == _selectedAccount?.id);
                    return Text(
                      "Số dư: ${selectedAccount != null ? NumberUtils.formatCurrency(selectedAccount.balance) : '0'}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }),
                ],
              )),
          // Period Selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'THÁNG TRƯỚC',
                  label: Text('THÁNG TRƯỚC'),
                ),
                ButtonSegment<String>(
                  value: 'THÁNG NÀY',
                  label: Text('THÁNG NÀY'),
                ),
                ButtonSegment<String>(
                  value: 'TƯƠNG LAI',
                  label: Text('TƯƠNG LAI'),
                ),
              ],
              selected: <String>{_selectedPeriod},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedPeriod = newSelection.first;
                  _getStartAndEndDate(); // Tính toán lại _startDate, _endDate
                  _loadTransactions();   // Gọi hàm _loadTransactions để load lại dữ liệu
                });
              },
            ),
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                final transactions = transactionProvider.transactions;
                double totalIncome = 0;
                double totalExpense = 0;

                for (final transaction in transactions) {
                  if (transaction.amount > 0) {
                    totalIncome += transaction.amount;
                  } else {
                    totalExpense += transaction.amount;
                  }
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tiền vào'),
                        Text(
                          NumberUtils.formatCurrency(totalIncome),
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tiền ra'),
                        Text(
                          NumberUtils.formatCurrency(totalExpense.abs()),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          NumberUtils.formatCurrency(totalIncome + totalExpense),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (totalIncome + totalExpense) >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Chuyển đến màn hình báo cáo chi tiết
                        Navigator.pushNamed(context, '/reports');
                      },
                      child: const Text('Xem báo cáo cho giai đoạn này'),
                    )
                  ],
                );
              },
            ),
          ),

          // Transaction List
          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator()) :
            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                final transactions = transactionProvider.transactions;

                // Nhóm giao dịch theo ngày
                final transactionsByDate = groupBy(transactions, (Transaction transaction) {
                  return _getDateOnly(transaction.transactionDate);
                });

                // Sắp xếp các ngày theo thứ tự giảm dần (mới nhất lên đầu)
                final sortedDates = transactionsByDate.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final transactionsForDate = transactionsByDate[date]!;
                      final totalAmountForDate = transactionsForDate.fold(
                          0.0,
                          (sum, transaction) => sum + transaction.amount);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  NumberUtils.formatCurrency(totalAmountForDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: totalAmountForDate < 0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...transactionsForDate
                              .map((transaction) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: transaction.amount < 0 ? Colors.red : Colors.green,
                              child: Icon(
                                getCategoryIcon(transaction.categoryName), // Thêm icon dựa vào categoryName
                                color: Colors.white,
                              ),
                            ),
                            title: Text(transaction.categoryName ?? 'N/A'),
                            subtitle: Text(transaction.description ?? ''), // Hiển thị description
                            trailing: Text(NumberUtils.formatCurrency(transaction.amount)),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/transaction-details',
                                arguments: transaction,
                              );
                            },
                              )).toList(),
                        ],
                      );
                    },
                  ),
                );
              }
            )
          )
        ],
      ),
      bottomNavigationBar:
          const CustomBottomNavigationBar(currentIndex: 1), // Chỉ số 1 tương ứng với "Số giao dịch"
    );
  }
}