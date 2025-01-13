import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/account_provider.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../utils/app_constants.dart';

class EditTransactionScreen extends StatefulWidget {
  final int transactionId;

  const EditTransactionScreen({Key? key, required this.transactionId})
      : super(key: key);

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  Account? _selectedAccount;
  Category? _selectedCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Transaction? _transaction;
  String _transactionType = 'Chi';

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  Future<void> _loadTransactionData() async {
    // Lấy data từ provider thay vì future
    final transaction = Provider.of<TransactionProvider>(context, listen: false)
        .transactions
        .firstWhereOrNull((element) => element.id == widget.transactionId);
    if (transaction != null) {
      _transaction = transaction;
      final accounts =
          Provider.of<AccountProvider>(context, listen: false).accounts;
      final categories =
          Provider.of<CategoryProvider>(context, listen: false).categories;

      setState(() {
        _selectedAccount =
            accounts.firstWhere((account) => account.id == transaction.accountId);
        _selectedCategory = categories
            .firstWhere((category) => category.id == transaction.categoryId);
        // Format số tiền ở đây
        _amountController.text = transaction.amount.abs().toInt().toString();
        _descriptionController.text = transaction.description ?? '';
        _selectedDate = transaction.transactionDate;
        _transactionType = transaction.amount < 0 ? 'Chi' : 'Thu';
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an account and a category')),
      );
      return;
    }

    double enteredAmount = double.parse(_amountController.text);
    // // Xử lý số tiền dựa trên loại giao dịch
    // if (_transactionType == 'Chi') {
    //   enteredAmount = enteredAmount.abs() * -1; // Đảm bảo số tiền là số âm cho khoản chi
    // } else {
    //   enteredAmount =
    //       enteredAmount.abs(); // Đảm bảo số tiền là số dương cho khoản thu
    // }
    final enteredDescription = _descriptionController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);

      // Lấy số tiền giao dịch cũ
      final oldAmount = _transaction!.amount;

      // Cập nhật giao dịch
      await transactionProvider.updateTransaction(
        Transaction(
          id: _transaction!.id,
          accountId: _selectedAccount!.id,
          categoryId: _selectedCategory!.id,
          amount: enteredAmount,
          description: enteredDescription,
          transactionDate: _selectedDate,
          createdAt: _transaction!.createdAt,
          updatedAt: DateTime.now(),
        ),
      );

      // Cập nhật số dư tài khoản
      final currentBalance = accountProvider.accounts.firstWhere((a) => a.id == _selectedAccount!.id).balance;
      await accountProvider.updateBalance(_selectedAccount!.id, currentBalance + (enteredAmount - oldAmount) );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update transaction: ${error.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa giao dịch'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final accounts = accountProvider.accounts;
                  return DropdownButtonFormField<Account>(
                    decoration:
                    const InputDecoration(labelText: 'Tài khoản'),
                    value: _selectedAccount,
                    onChanged: (Account? newValue) {
                      setState(() {
                        _selectedAccount = newValue;
                      });
                    },
                    items: accounts.map<DropdownMenuItem<Account>>(
                          (Account account) {
                        return DropdownMenuItem<Account>(
                          value: account,
                          child: Text(account.name),
                        );
                      },
                    ).toList(),
                    validator: (value) => value == null
                        ? 'Please select an account'
                        : null,
                  );
                },
              ),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final categories = categoryProvider.categories;
                  return DropdownButtonFormField<Category>(
                    decoration:
                    const InputDecoration(labelText: 'Danh mục'),
                    value: _selectedCategory,
                    onChanged: (Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    items: categories.map<DropdownMenuItem<Category>>(
                          (Category category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      },
                    ).toList(),
                    validator: (value) => value == null
                        ? 'Please select a category'
                        : null,
                  );
                },
              ),
              DropdownButtonFormField<String>(
                decoration:
                const InputDecoration(labelText: 'Loại giao dịch'),
                value: _transactionType,
                onChanged: (String? newValue) {
                  setState(() {
                    _transactionType = newValue!;
                    // Nếu đang là số âm và chuyển sang "Thu", hoặc ngược lại, nhân số tiền với -1
                    if ((_amountController.text.startsWith('-') &&
                        newValue == 'Thu') ||
                        (!_amountController.text.startsWith('-') &&
                            newValue == 'Chi')) {
                      if (_amountController.text.isNotEmpty) {
                        double currentAmount =
                        double.parse(_amountController.text);
                        _amountController.text =
                            (currentAmount * -1).toString();
                      }
                    }
                  });
                },
                items: <String>['Thu', 'Chi']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                    .toList(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số tiền'),
                keyboardType: TextInputType.number,
                controller: _amountController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mô tả'),
                controller: _descriptionController,
                // Không cần validator nếu mô tả là tùy chọn
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text('Chọn ngày'),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitData,
                child: const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}