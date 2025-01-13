import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_picker_utils.dart';
import '../../utils/app_constants.dart';
import '../../models/account.dart';
import '../../models/category.dart';

class AddTransactionFromImageScreen extends StatefulWidget {
  const AddTransactionFromImageScreen({Key? key}) : super(key: key);

  @override
  _AddTransactionFromImageScreenState createState() =>
      _AddTransactionFromImageScreenState();
}

class _AddTransactionFromImageScreenState
    extends State<AddTransactionFromImageScreen> {
  File? _image;
  bool _isLoading = false;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Account? _selectedAccount;
  Category? _selectedCategory;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image picking failed: $e");
      _showErrorDialog("Failed to pick image: $e");
    }
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

  Future<void> _processImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
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

    try {
      final imageBytes = await ImagePickerUtils.compressImage(_image!);
      final fileName = _image!.path.split('/').last;
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      await transactionProvider.createTransactionFromImage(
        accessToken: Provider.of<AuthProvider>(context, listen: false).token!,
        imageBytes: imageBytes,
        fileName: fileName,
        accountId: _selectedAccount!.id,
        categoryId: _selectedCategory!.id,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        description: _descriptionController.text,
        transactionDate: _selectedDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to process and add transaction: $error')),
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
        title: const Text('Thêm giao dịch từ ảnh'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),
            _buildImagePickerButtons(),
            _isLoading
                ? const LinearProgressIndicator()
                : const SizedBox(height: 0),
            Consumer<AccountProvider>(
              builder: (context, accountProvider, child) {
                final accounts = accountProvider.accounts;
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
                // You can add specific validation rules if needed
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
              onPressed: _isLoading ? null : _processImage,
              child: const Text('Xử lý ảnh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: _image == null
          ? const Center(child: Text('No image selected'))
          : Image.file(_image!, fit: BoxFit.cover),
    );
  }

  Widget _buildImagePickerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: () => _pickImage(ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Camera'),
        ),
        TextButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('Gallery'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
