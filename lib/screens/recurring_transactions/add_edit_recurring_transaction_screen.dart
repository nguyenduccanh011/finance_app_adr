import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_transaction_provider.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/recurring_transaction.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_drawer.dart';

class AddEditRecurringTransactionScreen extends StatefulWidget {
  final RecurringTransaction? recurringTransaction;

  const AddEditRecurringTransactionScreen(
      {Key? key, this.recurringTransaction})
      : super(key: key);

  @override
  _AddEditRecurringTransactionScreenState createState() =>
      _AddEditRecurringTransactionScreenState();
}

class _AddEditRecurringTransactionScreenState
    extends State<AddEditRecurringTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  Account? _selectedAccount;
  Category? _selectedCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  String _selectedFrequency = 'daily';
  int _selectedInterval = 1;
  bool _isLoading = false;
  RecurringTransaction? _recurringTransaction;
  bool _dataLoaded = false;

  String _selectedType = 'Chi';


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.recurringTransaction != null && !_dataLoaded) {
      _loadRecurringTransactionData();
    }
  }

  Future<void> _loadRecurringTransactionData() async {
    final accounts =
        Provider.of<AccountProvider>(context, listen: false).accounts;
    final categories =
        Provider.of<CategoryProvider>(context, listen: false).categories;
    setState(() {
      _selectedAccount = accounts.firstWhereOrNull(
              (account) => account.id == widget.recurringTransaction!.accountId);
      _selectedCategory = categories.firstWhereOrNull(
              (category) => category.id == widget.recurringTransaction!.categoryId);
      _amountController.text = widget.recurringTransaction!.amount.abs().toInt().toString();
      _descriptionController.text = widget.recurringTransaction!.description ?? '';
      _selectedType = widget.recurringTransaction!.type == 'income' ? 'Thu' : 'Chi';
      _selectedFrequency = widget.recurringTransaction!.frequency;
      _selectedInterval = widget.recurringTransaction!.interval;
      _selectedStartDate = widget.recurringTransaction!.startDate;
      _selectedEndDate = widget.recurringTransaction!.endDate;
      _dataLoaded = true;
    });
  }



  void _presentStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
      initialDate: _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedEndDate = pickedDate;
      });
    });
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

    setState(() {
      _isLoading = true;
    });

    final enteredAmount = double.parse(_amountController.text);
    final enteredDescription = _descriptionController.text;

    try {
      final recurringTransactionData = RecurringTransaction(
        id: widget.recurringTransaction != null ? widget.recurringTransaction!.id : 0, // Sửa ở đây
        userId: 0, // Replace with actual user ID if needed
        accountId: _selectedAccount!.id,
        categoryId: _selectedCategory!.id,
        amount: enteredAmount,
        description: enteredDescription,
        type: _selectedType == 'Thu' ? 'income' : 'expense', // Sửa ở đây
        frequency: _selectedFrequency,
        interval: _selectedInterval,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        nextOccurrence: _selectedStartDate, // This should be calculated based on frequency and interval
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.recurringTransaction == null) {
        await Provider.of<RecurringTransactionProvider>(context, listen: false)
            .createRecurringTransaction(recurringTransactionData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recurring transaction added successfully')),
        );
      } else {
        await Provider.of<RecurringTransactionProvider>(context, listen: false)
            .updateRecurringTransaction(recurringTransactionData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recurring transaction updated successfully')),
        );
      }
      Navigator.of(context).pop(true); // Truyền true để load lại danh sách
    } catch (error) {
      _showErrorDialog('Failed to save transaction: ${error.toString()}');
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
        title: Text(_recurringTransaction == null
        ? 'Thêm giao dịch định kỳ'
        : 'Sửa giao dịch định kỳ'),
    ),
      drawer: const CustomDrawer(),
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
    if (_selectedAccount == null && accounts.isNotEmpty) {
    _selectedAccount = accounts[0];
    }
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
    if (_selectedCategory == null && categories.isNotEmpty) {
    _selectedCategory = categories[0];
    }
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
        decoration: const InputDecoration(labelText: 'Loại giao dịch'),
        value: _selectedType,
        onChanged: (String? newValue) {
          setState(() {
            _selectedType = newValue!;
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
        validator: (value) =>
        value == null ? 'Please select a transaction type' : null,
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
    DropdownButtonFormField<String>(
    decoration: const InputDecoration(labelText: 'Tần suất'),
    value: _selectedFrequency,
    onChanged: (String? newValue) {
    setState(() {
    _selectedFrequency = newValue!;
    });
    },
    items: <String>['daily', 'weekly', 'monthly', 'yearly']
        .map<DropdownMenuItem<String>>(
    (String value) => DropdownMenuItem<String>(
    value: value,
    child: Text(value),
    ),
    )
        .toList(),
    validator: (value) =>
    value == null ? 'Please select a frequency' : null,
    ),
    TextFormField(
    decoration: const InputDecoration(
    labelText: 'Số lần lặp lại (interval)'),
      keyboardType: TextInputType.number,
      initialValue: _selectedInterval.toString(),
      onChanged: (value) {
        setState(() {
          _selectedInterval = int.tryParse(value) ?? 1;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an interval';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    ),
      const SizedBox(height: AppConstants.defaultSpacing),
      Row(
        children: [
          Expanded(
            child: Text(
              'Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate)}',
            ),
          ),
          TextButton(
            onPressed: _presentStartDatePicker,
            child: const Text('Chọn ngày'),
          ),
        ],
      ),
      const SizedBox(height: AppConstants.defaultSpacing),
      Row(
        children: [
          Expanded(
            child: Text(
              _selectedEndDate == null
                  ? 'Ngày kết thúc: Không giới hạn'
                  : 'Ngày kết thúc: ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}',
            ),
          ),
          TextButton(
            onPressed: _presentEndDatePicker,
            child: const Text('Chọn ngày'),
          ),
        ],
      ),
      const SizedBox(height: AppConstants.defaultSpacing),
      ElevatedButton(
        onPressed: _isLoading ? null : _submitData,
        child: const Text('Lưu'),
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