import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../utils/app_constants.dart';
import 'add_transaction_from_image_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  Account? _selectedAccount;
  Category? _selectedCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String _transactionType = 'Chi';

  @override
  void initState() {
    super.initState();
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
          content: Text('Please select an account and a category'),
        ),
      );
      return;
    }

    double enteredAmount = double.parse(_amountController.text);

    // Xử lý số tiền dựa trên loại giao dịch
    if (_transactionType == 'Chi') {
      enteredAmount = enteredAmount.abs() * -1; // Chuyển thành số âm nếu là Chi
    } else {
      enteredAmount = enteredAmount.abs(); // Đảm bảo là số dương nếu là Thu
    }


    final enteredDescription = _descriptionController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TransactionProvider>(context, listen: false)
          .createTransaction(
        accountId: _selectedAccount!.id,
        categoryId: _selectedCategory!.id,
        amount: enteredAmount,
        description: enteredDescription,
        transactionDate: _selectedDate,
      );

      // Cập nhật số dư tài khoản
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      final currentBalance = accountProvider.accounts.firstWhere((a) => a.id == _selectedAccount!.id).balance;
      await accountProvider.updateBalance(_selectedAccount!.id, currentBalance + enteredAmount);


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully')),
      );
      Navigator.of(context).pop(); // Close the screen after adding
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add transaction: ${error.toString()}'),
        ),
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
        title: const Text('Thêm giao dịch'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _isLoading
                  ? const LinearProgressIndicator()
                  : const SizedBox(height: 0),
              Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final accounts = accountProvider.accounts;
                  if (accounts.isEmpty) {
                    return const Text('No accounts available');
                  }
                  if (_selectedAccount == null && accounts.isNotEmpty) {
                    _selectedAccount = accounts[0];
                  }

                  return DropdownButtonFormField<Account>(
                    decoration: const InputDecoration(labelText: 'Tài khoản'),
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
                    validator: (value) =>
                    value == null ? 'Please select an account' : null,
                  );
                },
              ),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final categories = categoryProvider.categories;
                  if (_selectedCategory == null && categories.isNotEmpty) {
                    _selectedCategory = categories[0];
                  }
                  return DropdownButtonFormField<Category>(
                    decoration: const InputDecoration(labelText: 'Danh mục'),
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
                    validator: (value) =>
                    value == null ? 'Please select a category' : null,
                  );
                },
              ),
              // Thêm DropdownButtonFormField để chọn loại giao dịch
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại giao dịch'),
                value: _transactionType,
                onChanged: (String? newValue) {
                  setState(() {
                    _transactionType = newValue!;
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
                validator: (value) {
                  return null;
                },
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
                child: const Text('Thêm giao dịch'),
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTransactionFromImageScreen(),
                    ),
                  );
                },
                child: const Text('Thêm từ ảnh hóa đơn'),
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