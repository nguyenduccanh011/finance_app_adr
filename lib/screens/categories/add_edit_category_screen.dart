import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart' as model_category;
import '../../utils/app_constants.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final int? categoryId;

  const AddEditCategoryScreen({Key? key, this.categoryId}) : super(key: key);

  @override
  _AddEditCategoryScreenState createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedCategoryType = 'expense'; // Mặc định là chi tiêu
  bool _isLoading = false;
  model_category.Category? _category;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _loadCategory();
    }
  }

  Future<void> _loadCategory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final category =
          await Provider.of<CategoryProvider>(context, listen: false)
              .getCategory(widget.categoryId!);
      setState(() {
        _category = category;
        _nameController.text = _category!.name;
        _selectedCategoryType = _category!.type;
      });
    } catch (error) {
      print('Error loading category: $error');
      _showErrorDialog('Failed to load category details.');
    } finally {
      setState(() {
        _isLoading = false;
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

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text;

    try {
      if (_category == null) {
        await Provider.of<CategoryProvider>(context, listen: false)
            .createCategory(name, _selectedCategoryType);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created successfully')),
        );
      } else {
        await Provider.of<CategoryProvider>(context, listen: false)
            .updateCategory(
          model_category.Category(
            id: _category!.id,
            userId: _category!.userId,
            name: name,
            type: _selectedCategoryType,
            createdAt: _category!.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      }
      Navigator.of(context).pop();
    } catch (error) {
      _showErrorDialog('Failed to save category: ${error.toString()}');
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
        title: Text(_category == null ? 'Thêm danh mục' : 'Sửa danh mục'),
      ),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Tên danh mục'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên danh mục';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryType,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategoryType = newValue!;
                        });
                      },
                      items: <String>['income', 'expense']
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                  value == 'income' ? 'Thu nhập' : 'Chi tiêu'),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(labelText: 'Loại'),
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 4),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
