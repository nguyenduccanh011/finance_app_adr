import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/account.dart';
import '../../utils/app_constants.dart';

class AddEditAccountScreen extends StatefulWidget {
  final Account? account;

  const AddEditAccountScreen({Key? key, this.account}) : super(key: key);

  @override
  _AddEditAccountScreenState createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _isLoading = false;
  //Account? _account;
  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance.toInt().toString();
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

  void _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text;
    final balance = double.parse(_balanceController.text);

    try {
      if (widget.account == null) { // Sửa thành widget.account
        // Thêm mới
        await Provider.of<AccountProvider>(context, listen: false)
            .createAccount(name, balance);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
      } else {
        // Cập nhật
        await Provider.of<AccountProvider>(context, listen: false)
            .updateAccount(
          Account(
            id: widget.account!.id, // Sửa thành widget.account
            userId: widget.account!.userId, // Sửa thành widget.account
            name: name,
            balance: balance,
            createdAt: widget.account!.createdAt, // Sửa thành widget.account
            updatedAt: DateTime.now(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account updated successfully')),
        );
      }
      Navigator.of(context).pop();
    } catch (error) {
      _showErrorDialog('Failed to save account: ${error.toString()}');
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
        title: Text(widget.account == null ? 'Thêm tài khoản' : 'Sửa tài khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                const InputDecoration(labelText: 'Tên tài khoản'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên tài khoản';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(labelText: 'Số dư'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số dư';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Số dư không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAccount,
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
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
}
