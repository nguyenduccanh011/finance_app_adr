// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tesst_app/widgets/custom_bottom_navigation_bar.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../utils/app_constants.dart';
import '../../utils/number_utils.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<String> _reportTypes = ['Theo danh mục', 'Theo thời gian'];
  String _selectedReportType = 'Theo danh mục';
  DateTime _selectedStartDate =
  DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;
    final transactionProvider =
    Provider.of<TransactionProvider>(context, listen: false);
    await transactionProvider.fetchTransactions(
        startDate: _selectedStartDate.toIso8601String().split('T')[0],
        endDate: _selectedEndDate.toIso8601String().split('T')[0]);
  }

  void _presentStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedStartDate = pickedDate;
      });
    });
  }

  void _presentEndDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedEndDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            _buildFilterOptions(),
            const SizedBox(height: AppConstants.defaultSpacing),
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, transactionProvider, child) {
                  final transactions = transactionProvider.transactions;
                  if (transactions.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  return _selectedReportType == 'Theo danh mục'
                      ? _buildCategoryReport(transactions)
                      : _buildMonthlyExpenseReport(transactions);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      children: [
        DropdownButtonFormField2(
          value: _selectedReportType,
          items: _reportTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedReportType = value!;
              if (_selectedReportType == 'Theo thời gian') {
                // Set the selected start date to the first day of 3 months ago
                DateTime threeMonthsAgo =
                DateTime.now().subtract(const Duration(days: 90));
                _selectedStartDate =
                    DateTime(threeMonthsAgo.year, threeMonthsAgo.month, 1);
                // Ensure end date is still today's date
                _selectedEndDate = DateTime.now();
              }
            });
          },
          decoration: const InputDecoration(labelText: 'Loại báo cáo'),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200, // Ensure dropdown does not exceed 200px in height
            offset: const Offset(0, 8), // Space below the dropdown
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextButton(
                onPressed: _presentStartDatePicker,
                child: Text(
                    'Từ: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate)}'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: _presentEndDatePicker,
                child: Text(
                    'Đến: ${DateFormat('dd/MM/yyyy').format(_selectedEndDate)}'),
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            _loadTransactions();
          },
          child: const Text('Tải báo cáo'),
        ),
      ],
    );
  }

  Widget _buildCategoryReport(List<Transaction> transactions) {
    // Tạo dữ liệu danh mục và tổng giá trị
    Map<String, double> categoryData = {};
    double totalSpent = 0;

    for (var transaction in transactions) {
      if (transaction.amount < 0) {
        totalSpent += transaction.amount.abs(); // Tính tổng tiền đã tiêu
        categoryData.update(
          transaction.categoryName ?? 'N/A',
              (value) => value + transaction.amount.abs(),
          ifAbsent: () => transaction.amount.abs(),
        );
      }
    }

    // Hàm tạo màu ngẫu nhiên tối
    Color getRandomDarkColor() {
      Random random = Random();
      return Color.fromRGBO(
        random.nextInt(180), // Red (giới hạn giá trị nhỏ để tạo màu tối)
        random.nextInt(180), // Green (giới hạn giá trị nhỏ để tạo màu tối)
        random.nextInt(180), // Blue (giới hạn giá trị nhỏ để tạo màu tối)
        1, // Alpha (opacity)
      );
    }

    // Ánh xạ danh mục với màu sắc ngẫu nhiên tối
    final Map<String, Color> categoryColors = {};
    categoryData.forEach((category, _) {
      if (!categoryColors.containsKey(category)) {
        categoryColors[category] =
            getRandomDarkColor(); // Gán màu ngẫu nhiên tối cho danh mục
      }
    });

    // Chuyển đổi dữ liệu cho Pie Chart
    List<PieChartSectionData> pieChartSections =
    categoryData.entries.map((entry) {
      final percentage = (entry.value / totalSpent * 100).toStringAsFixed(1);
      final color =
          categoryColors[entry.key] ?? Colors.grey; // Màu mặc định là grey

      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '$percentage%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        // Hiển thị biểu đồ Pie Chart với tổng tiền ở giữa
        Card(
          color: Colors.blueGrey[50], // Đặt màu nền cho Card
          elevation: 4.0, // Hiệu ứng nổi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Bo góc
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Khoảng cách bên trong
            child: SizedBox(
              width: 300, // Đặt chiều rộng cố định
              height: 300, // Đặt chiều cao cố định
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      centerSpaceRadius: 70, // Thu nhỏ khoảng trống ở giữa
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(enabled: false),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tiền đã tiêu',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          NumberUtils.formatCurrency(-totalSpent),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 19.0, // Khoảng cách cố định giữa Card và ListView
        ),

        // Hiển thị tổng giá trị theo từng danh mục với màu chữ ngẫu nhiên dưới dạng indicator bar
        Expanded(
          child: ListView(
            children: categoryData.entries.map((entry) {
              final color =
                  categoryColors[entry.key] ?? Colors.grey; // Màu mặc định
              final barWidth = (entry.value / totalSpent) *
                  MediaQuery.of(context)
                      .size
                      .width; // Chiều dài thanh indicator dựa trên tỷ lệ

              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0), // Căn lề cho từng mục
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên danh mục và giá trị
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.black, // Màu chữ đen
                              fontSize: 16, // Kích thước chữ cho tên danh mục
                              fontWeight: FontWeight.bold, // In đậm
                            ),
                          ),
                        ),
                        Text(
                          NumberUtils.formatCurrency(-entry.value),
                          style: const TextStyle(
                            color: Colors.black, // Màu chữ đen
                            fontSize: 14, // Kích thước chữ cho giá trị
                            fontWeight: FontWeight.bold, // In đậm
                          ),
                        ),
                      ],
                    ),

                    // Khoảng cách giữa chữ và thanh indicator
                    const SizedBox(
                      height: 8.0, // Tăng khoảng cách giữa chữ và thanh
                    ),

                    // Thanh indicator bar với độ dài theo tỷ lệ phần trăm
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: barWidth -
                            32, // Trừ lề hai bên (horizontal padding)
                        height: 6,
                        decoration: BoxDecoration(
                          color: color, // Màu thanh theo danh mục
                          borderRadius: BorderRadius.circular(
                              4.0), // Bo tròn các góc thanh
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyExpenseReport(List<Transaction> transactions) {
    // Group transactions by month
    Map<String, double> monthlyIncome = {};
    Map<String, double> monthlyExpense = {};

    for (var transaction in transactions) {
      if (transaction.transactionDate.isBefore(DateTime.now()) ||
          (transaction.transactionDate.year == DateTime.now().year &&
              transaction.transactionDate.month == DateTime.now().month &&
              transaction.transactionDate.day <= DateTime.now().day)) {
        // Normalize the date to the first of the month
        DateTime date = DateTime(
            transaction.transactionDate.year, transaction.transactionDate.month);
        String monthKey = DateFormat('yyyy-MM').format(date);

        if (transaction.amount < 0) {
          // Expense (negative value)
          monthlyExpense.update(
            monthKey,
                (value) => value + transaction.amount.abs(),
            ifAbsent: () => transaction.amount.abs(),
          );
        } else {
          // Income (positive value)
          monthlyIncome.update(
            monthKey,
                (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }
      }
    }

    // Get the last 3 months, including the current month but only up to today's date
    DateTime now = DateTime.now();
    List<String> lastSixMonths = [
      // Four months ago
      DateFormat('yyyy-MM').format(now.subtract(const Duration(days: 90))),
      DateFormat('yyyy-MM')
          .format(now.subtract(Duration(days: 60))), // Two months ago
      DateFormat('yyyy-MM')
          .format(now.subtract(Duration(days: 30))), // One month ago
      DateFormat('yyyy-MM').format(now), // Current month
    ];

    // Prepare data for BarChart
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < lastSixMonths.length; i++) {
      String month = lastSixMonths[i];

      double totalIncome = monthlyIncome[month] ?? 0.0;
      double totalExpense = monthlyExpense[month] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i, // Position of the bar on X-axis
          barsSpace: 6, // Space between bars
          barRods: [
            // Bar for expense (chi)
            BarChartRodData(
              toY: totalExpense, // Positive value to show above the X-axis
              color: Colors.red, // Color for expense
              width: 20, // Width for the bar
              borderRadius: BorderRadius.circular(4), // Sharp corners
            ),
            // Bar for income (thu)
            BarChartRodData(
              toY: totalIncome, // Positive value to show above the X-axis
              color: Colors.green, // Color for income
              width: 20, // Width for the bar
              borderRadius: BorderRadius.circular(4), // Sharp corners
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // value: giá trị số (0, 1, 2), ánh xạ tới tháng tương ứng
                  int monthIndex = value.toInt();
                  if (monthIndex >= 0 && monthIndex < lastSixMonths.length) {
                    String month = lastSixMonths[monthIndex];
                    return Text(
                      DateFormat('MM/yyyy').format(DateTime.parse('$month-01')),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 192, 13, 58),
                      ),
                    );
                  }
                  return const SizedBox(); // Trả về khoảng trống nếu không hợp lệ
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hide left titles
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hide left titles
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hide left titles
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          gridData: FlGridData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}

Widget _buildMonthlyExpenseReport(List<Transaction> transactions) {
  // Group transactions by month
  Map<String, double> monthlyIncome = {};
  Map<String, double> monthlyExpense = {};

  for (var transaction in transactions) {
    if (transaction.transactionDate.isBefore(DateTime.now()) ||
        (transaction.transactionDate.year == DateTime.now().year &&
            transaction.transactionDate.month == DateTime.now().month &&
            transaction.transactionDate.day <= DateTime.now().day)) {
      // Normalize the date to the first of the month
      DateTime date = DateTime(
          transaction.transactionDate.year, transaction.transactionDate.month);
      String monthKey = DateFormat('yyyy-MM').format(date);

      if (transaction.amount < 0) {
        // Expense (negative value)
        monthlyExpense.update(
          monthKey,
              (value) => value + transaction.amount.abs(),
          ifAbsent: () => transaction.amount.abs(),
        );
      } else {
        // Income (positive value)
        monthlyIncome.update(
          monthKey,
              (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }
  }

  // Get the last 3 months, including the current month but only up to today's date
  DateTime now = DateTime.now();
  List<String> lastSixMonths = [
    // Four months ago
    DateFormat('yyyy-MM').format(now.subtract(const Duration(days: 90))),
    DateFormat('yyyy-MM')
        .format(now.subtract(Duration(days: 60))), // Two months ago
    DateFormat('yyyy-MM')
        .format(now.subtract(Duration(days: 30))), // One month ago
    DateFormat('yyyy-MM').format(now), // Current month
  ];

  // Prepare data for BarChart
  List<BarChartGroupData> barGroups = [];
  for (int i = 0; i < lastSixMonths.length; i++) {
    String month = lastSixMonths[i];

    double totalIncome = monthlyIncome[month] ?? 0.0;
    double totalExpense = monthlyExpense[month] ?? 0.0;

    barGroups.add(
      BarChartGroupData(
        x: i, // Position of the bar on X-axis
        barsSpace: 6, // Space between bars
        barRods: [
          // Bar for expense (chi)
          BarChartRodData(
            toY: totalExpense, // Positive value to show above the X-axis
            color: Colors.red, // Color for expense
            width: 20, // Width for the bar
            borderRadius: BorderRadius.circular(4), // Sharp corners
          ),
          // Bar for income (thu)
          BarChartRodData(
            toY: totalIncome, // Positive value to show above the X-axis
            color: Colors.green, // Color for income
            width: 20, // Width for the bar
            borderRadius: BorderRadius.circular(4), // Sharp corners
          ),
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // value: giá trị số (0, 1, 2), ánh xạ tới tháng tương ứng
                int monthIndex = value.toInt();
                if (monthIndex >= 0 && monthIndex < lastSixMonths.length) {
                  String month = lastSixMonths[monthIndex];
                  return Text(
                    DateFormat('MM/yyyy').format(DateTime.parse('$month-01')),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 192, 13, 58),
                    ),
                  );
                }
                return const SizedBox(); // Trả về khoảng trống nếu không hợp lệ
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false, // Hide left titles
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        gridData: FlGridData(show: false),
        barGroups: barGroups,
      ),
    ),
  );
}
