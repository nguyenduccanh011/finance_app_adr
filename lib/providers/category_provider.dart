import 'package:flutter/foundation.dart';
import '../api/category_api.dart';
import '../models/category.dart' as model_category;
import 'auth_provider.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryApi _categoryApi;
  final AuthProvider _authProvider;
  List<model_category.Category> _categories = [];

  CategoryProvider(this._categoryApi, this._authProvider) {
    // Chỉ fetch data nếu đã đăng nhập
    if (_authProvider.isAuthenticated) {
      fetchCategories();
    }
  }

  List<model_category.Category> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      // Kiểm tra token trước khi gọi API
      if (_authProvider.token != null) {
        final data = await _categoryApi.getCategories(accessToken: _authProvider.token!);
        if (data is List) {
          _categories = data.map<model_category.Category>((json) => model_category.Category.fromJson(json)).toList();
          notifyListeners();
        } else {
          throw Exception("Expected a list of categories but received: ${data.runtimeType}");
        }
      } else {
        print('Token is null. Cannot fetch categories.');
        // Có thể throw exception ở đây nếu cần thiết
      }
    } catch (error) {
      // Xử lý lỗi
      print('Error fetching categories: $error');
      rethrow;
    }
  }

  Future<model_category.Category> getCategory(int categoryId) async {
    try {
      // Kiểm tra token trước khi gọi API
      if (_authProvider.token != null) {
        final response = await _categoryApi.getCategory(
          accessToken: _authProvider.token!,
          categoryId: categoryId,
        );
        if (response.isEmpty) {
          throw Exception('Category not found');
        }
        return model_category.Category.fromJson(response);
      } else {
        print('Token is null. Cannot fetch category.');
        throw Exception('Authentication required to fetch category.');
      }
    } catch (error) {
      print('Error fetching category: $error');
      rethrow;
    }
  }

  Future<void> createCategory(String name, String type) async {
    try {
      // Kiểm tra token trước khi gọi API
      if (_authProvider.token != null) {
        final newCategory = await _categoryApi.createCategory(
          accessToken: _authProvider.token!,
          name: name,
          type: type,
        );
        print("Response from createCategory: $newCategory"); // In ra response

        // Thêm dòng kiểm tra giá trị null
        if (newCategory['id'] == null || newCategory['name'] == null || newCategory['type'] == null) {
          throw Exception("Server returned null value for required fields: $newCategory");
        }

        _categories.add(model_category.Category.fromJson(newCategory));
        notifyListeners();
      } else {
        print('Token is null. Cannot create category.');
        // Có thể throw exception ở đây nếu cần thiết
      }
    } catch (error) {
      // Xử lý lỗi
      print('Error creating category: $error');
      rethrow;
    }
  }

  Future<void> updateCategory(model_category.Category updatedCategory) async {
    try {
      // Kiểm tra token trước khi gọi API
      if (_authProvider.token != null) {
        await _categoryApi.updateCategory(
          accessToken: _authProvider.token!,
          categoryId: updatedCategory.id,
          category: updatedCategory,
        );
        final index = _categories.indexWhere((category) => category.id == updatedCategory.id);
        if (index != -1) {
          _categories[index] = updatedCategory;
          notifyListeners();
        }
      } else {
        print('Token is null. Cannot update category.');
        // Có thể throw exception ở đây nếu cần thiết
      }
    } catch (error) {
      // Xử lý lỗi
      print('Error updating category: $error');
      rethrow;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      // Kiểm tra token trước khi gọi API
      if (_authProvider.token != null) {
        await _categoryApi.deleteCategory(
          accessToken: _authProvider.token!,
          categoryId: categoryId,
        );
        _categories.removeWhere((category) => category.id == categoryId);
        notifyListeners();
      } else {
        print('Token is null. Cannot delete category.');
        // Có thể throw exception ở đây nếu cần thiết
      }
    } catch (error) {
      // Xử lý lỗi
      print('Error deleting category: $error');
      rethrow;
    }
  }
}