import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/budget.dart';
import '../../models/category.dart' as model_category;
import '../../utils/app_constants.dart';
import '../../widgets/custom_drawer.dart';

class AddEditBudgetScreen extends StatefulWidget {
  final Budget? budget; // Sửa thành nhận budget object

  const AddEditBudgetScreen({Key? key, this.budget}) : super(key: key);

  @override
  _AddEditBudgetScreenState createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  model_category.Category? _selectedCategory;
  final _amountController = TextEditingController();
  String _selectedPeriod = 'monthly'; // Default period
  DateTime _selectedStartDate = DateTime.now();
  bool _isLoading = false;
  bool _dataLoaded = false;

  // Bỏ initState()

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.budget != null && !_dataLoaded) {
      _loadBudgetData();
    }
  }

  Future<void> _loadBudgetData() async {
    final categories =
        Provider.of<CategoryProvider>(context, listen: false).categories;
    setState(() {
      _selectedCategory = categories.firstWhereOrNull(
              (category) => category.id == widget.budget!.categoryId);
      _amountController.text = widget.budget!.amount.toInt().toString();
      _selectedPeriod = widget.budget!.period;
      _selectedStartDate = widget.budget!.startDate;
      _dataLoaded = true;
    });
  }

  // Bỏ _loadBudget()

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

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final enteredAmount = double.parse(_amountController.text);

    print("Selected Category ID: ${_selectedCategory?.id}");
    try {
      if (widget.budget == null) {
        // Thêm mới
        await Provider.of<BudgetProvider>(context, listen: false).createBudget(
          _selectedCategory!.id,
          enteredAmount,
          _selectedPeriod,
          _selectedStartDate,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget created successfully')),
        );
      } else {
        // Cập nhật
        // Sửa lại phần truyền giá trị cho updateBudget
        await Provider.of<BudgetProvider>(context, listen: false).updateBudget(
          Budget(
            id: widget.budget!.id,
            categoryId: _selectedCategory!.id, // Lấy id từ _selectedCategory
            categoryName: _selectedCategory!.name, // Lấy name từ _selectedCategory (hoặc widget.budget!.categoryName nếu cần)
            amount: enteredAmount,
            period: _selectedPeriod,
            startDate: _selectedStartDate,
            createdAt: widget.budget!.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget updated successfully')),
        );
      }
      Navigator.of(context).pop(true); // Trả về true sau khi lưu thành công
    } catch (error) {
      _showErrorDialog('Failed to save budget: ${error.toString()}');
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
        title: Text(widget.budget == null ? 'Thêm ngân sách' : 'Sửa ngân sách'),
      ),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final categories = categoryProvider.categories;
                  // Cập nhật giá trị của _selectedCategory nếu chưa được chọn
                  if (_selectedCategory == null &&
                      categories.isNotEmpty &&
                      widget.budget != null) {
                    _selectedCategory = categories.firstWhereOrNull(
                            (c) => c.id == widget.budget!.categoryId);
                  }
                  return DropdownButtonFormField<model_category.Category>(
                    decoration:
                    const InputDecoration(labelText: 'Danh mục'),
                    value: _selectedCategory,
                    onChanged: (model_category.Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    items: categories
                        .map<DropdownMenuItem<model_category.Category>>(
                          (model_category.Category category) =>
                          DropdownMenuItem<model_category.Category>(
                            value: category,
                            child: Text(category.name),
                          ),
                    )
                        .toList(),
                    validator: (value) => value == null
                        ? 'Please select a category'
                        : null,
                  );
                },
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Chu kỳ'),
                value: _selectedPeriod,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPeriod = newValue!;
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
                value == null ? 'Please select a period' : null,
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
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBudget,
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
    super.dispose();
  }
}