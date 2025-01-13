import 'api_client.dart';

class BudgetApi {
  final ApiClient _apiClient;

  BudgetApi(this._apiClient);

  Future<List<dynamic>> getBudgets({required String accessToken}) {
    return _apiClient.get(
      '/budgets',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> createBudget({
    required String accessToken,
    required int categoryId,
    required double amount,
    required String period,
    required String startDate,
  }) {
    return _apiClient.post(
      '/budgets',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'category_id': categoryId,
        'amount': amount,
        'period': period,
        'start_date': startDate,
      },
    );
  }

  Future<List<dynamic>> getBudgetsByUserId({required String accessToken}) {
    return _apiClient.get(
      '/budgets',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> getBudgetById( // Sửa kiểu trả về thành Future<dynamic>
          {required String accessToken, required int budgetId}) async {
    final dynamic response = await _apiClient.get(
      '/budgets/$budgetId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<dynamic> updateBudget({
    required String accessToken,
    required int budgetId,
    required int categoryId,
    required double amount,
    required String period,
    required String startDate,
  }) {
    return _apiClient.put(
      '/budgets/$budgetId',
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json', // Thêm header này
      },
      body: {
        'category_id': categoryId,
        'amount': amount,
        'period': period,
        'start_date': startDate,
      },
    );
  }

  Future<dynamic> deleteBudget(
      {required String accessToken, required int budgetId}) {
    return _apiClient.delete(
      '/budgets/$budgetId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}

