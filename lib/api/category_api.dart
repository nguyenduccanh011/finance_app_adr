import 'package:tesst_app/models/category.dart';

import 'api_client.dart';

class CategoryApi {
  final ApiClient _apiClient;

  CategoryApi(this._apiClient);

  Future<List<dynamic>> getCategories({required String accessToken}) {
    return _apiClient.get(
      '/categories',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> createCategory(
      {required String accessToken,
      required String name,
      required String type}) {
    return _apiClient.post(
      '/categories',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'name': name, 'type': type},
    );
  }

  Future<dynamic> getCategory(
      {required String accessToken, required int categoryId}) {
    return _apiClient.get(
      '/categories/$categoryId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> updateCategory(
      {required String accessToken,
      required int categoryId,
      required Category category}) {
    return _apiClient.put(
      '/categories/$categoryId',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: category.toJson(),
    );
  }

  Future<dynamic> deleteCategory(
      {required String accessToken, required int categoryId}) {
    return _apiClient.delete(
      '/categories/$categoryId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
