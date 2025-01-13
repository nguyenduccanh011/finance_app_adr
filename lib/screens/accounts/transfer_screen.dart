import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesst_app/providers/transaction_provider.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../utils/app_constants.dart';


class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  Account? _selectedSourceAccount;
  Account? _selectedDestinationAccount;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedSourceAccount == null || _selectedDestinationAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tài khoản nguồn và đích')),
      );
      return;
    }

    if (_selectedSourceAccount!.id == _selectedDestinationAccount!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tài khoản nguồn và đích phải khác nhau')),
      );
      return;
    }

    final double amount = double.parse(_amountController.text);

    try {
      // Cập nhật số dư tài khoản nguồn
      await Provider.of<AccountProvider>(context, listen: false).updateBalance(
        _selectedSourceAccount!.id,
        _selectedSourceAccount!.balance - amount,
      );

      // Cập nhật số dư tài khoản đích
      await Provider.of<AccountProvider>(context, listen: false).updateBalance(
        _selectedDestinationAccount!.id,
        _selectedDestinationAccount!.balance + amount,
      );

      // Thêm giao dịch (có thể thêm logic để lưu lịch sử chuyển khoản)

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chuyển khoản thành công')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chuyển khoản thất bại: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final accounts = accountProvider.accounts;
                  return DropdownButtonFormField<Account>(
                    decoration: const InputDecoration(labelText: 'Từ tài khoản'),
                    value: _selectedSourceAccount,
                    onChanged: (Account? newValue) {
                      setState(() {
                        _selectedSourceAccount = newValue;
                      });
                    },
                    items: accounts
                        .map<DropdownMenuItem<Account>>(
                            (Account account) => DropdownMenuItem<Account>(
                          value: account, // Kiểm tra giá trị này
                          child: Text(account.name),
                        ))
                        .toList(),
                    validator: (value) => value == null
                        ? 'Vui lòng chọn tài khoản nguồn'
                        : null,
                  );
                },
              ),
              Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final accounts = accountProvider.accounts;
                  return DropdownButtonFormField<Account>(
                    decoration: const InputDecoration(labelText: 'Đến tài khoản'),
                    value: _selectedDestinationAccount,
                    onChanged: (Account? newValue) {
                      setState(() {
                        _selectedDestinationAccount = newValue;
                      });
                    },
                    items: accounts
                        .map<DropdownMenuItem<Account>>(
                            (Account account) => DropdownMenuItem<Account>(
                          value: account, // Kiểm tra giá trị này
                          child: Text(account.name),
                        ))
                        .toList(),
                    validator: (value) => value == null
                        ? 'Vui lòng chọn tài khoản đích'
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
                    return 'Vui lòng nhập số tiền';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Vui lòng nhập số hợp lệ';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mô tả (tùy chọn)'),
                controller: _descriptionController,
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              ElevatedButton(
                onPressed: _submitTransfer,
                child: const Text('Chuyển khoản'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}