import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/category_list_item.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';

class CategoriesManagerScreen extends StatefulWidget {
  const CategoriesManagerScreen({Key? key}) : super(key: key);

  @override
  _CategoriesManagerScreenState createState() =>
      _CategoriesManagerScreenState();
}

class _CategoriesManagerScreenState extends State<CategoriesManagerScreen> {
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
      ),
      drawer: const CustomDrawer(),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          final categories = categoryProvider.categories;
          if (categories.isEmpty) {
            return const Center(child: Text('Không có danh mục nào.'));
          }
          return RefreshIndicator(
            onRefresh: _loadCategories,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryListItem(
                  category: category,
                  onTap: () {
                    // Có thể xem chi tiết danh mục nếu cần
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      '/add-edit-category',
                      arguments: category.id,
                    );
                  },
                  onDelete: () {
                    _showDeleteConfirmationDialog(context, category.id);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-edit-category');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 4),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int categoryId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: const Text('Bạn có chắc chắn muốn xóa danh mục này?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Không'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Có'),
            onPressed: () {
              Provider.of<CategoryProvider>(context, listen: false)
                  .deleteCategory(categoryId)
                  .then((_) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa danh mục')),
                );
              }).catchError((error) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa thất bại: $error')),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
