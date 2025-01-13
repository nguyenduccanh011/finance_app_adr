import 'package:flutter/foundation.dart';
import '../api/budget_api.dart';
import '../models/budget.dart';
import 'auth_provider.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetApi _budgetApi;
  final AuthProvider _authProvider;
  List<Budget> _budgets = []; // Danh sách ngân sách
  Budget? _selectedBudget; // Ngân sách chi tiết

  BudgetProvider(this._budgetApi, this._authProvider) {
    if (_authProvider.isAuthenticated) {
      // fetchBudgets();
    }
  }

  List<Budget> get budgets => _budgets;

  Future<void> fetchBudgets() async {
    try {
      if (_authProvider.token != null) {
        final data = await _budgetApi.getBudgetsByUserId(accessToken: _authProvider.token!);
        print('Data type in fetchBudgets: ${data.runtimeType}'); // Thêm dòng này
        if (data is List) {
          _budgets = data.map<Budget>((json) => Budget.fromJson(json)).toList(); // Cập nhật _budgets
        } else {
          throw Exception("Expected a list of budgets but received: ${data.runtimeType}");
        }
        notifyListeners();
      } else {
        print('Token is null. Cannot fetch budgets.');
        // Có thể throw exception ở đây nếu cần thiết
      }
    } catch (error) {
      // Xử lý lỗi
      print('fetchBudgets error: ${error}');
      rethrow;
    }
  }
  Future<Budget?> getBudget(int budgetId) async {
    try {
      if (_authProvider.token != null) {
        print('Budgets before getBudget: $_budgets');
        final response = await _budgetApi.getBudgetById(
          accessToken: _authProvider.token!,
          budgetId: budgetId,
        );
        print('Response type in getBudget: ${response.runtimeType}');
        print('Response data in getBudget: $response');

        if (response is Map<String, dynamic> && response.containsKey('id')) {
          print('Budgets after getBudget: $_budgets');
          final budget = Budget.fromJson(response);
          print('Budget after fromJson: $budget');
          return budget;
        } else {
          print('Budget not found or invalid response format');
          return null;
        }
      } else {
        print('Token is null. Cannot get budget.');
        return null;
      }
    } catch (error) {
      print('Error get budget: $error');
      return null;
    }
  }
// Getter cho _selectedBudget (đặt ngoài hàm getBudget)
  Budget? get selectedBudget => _selectedBudget;

  Future<void> createBudget(
      int categoryId, double amount, String period, DateTime startDate) async {
    try {
      if (_authProvider.token != null) {
        final dynamic newBudget = await _budgetApi.createBudget(
          accessToken: _authProvider.token!,
          categoryId: categoryId,
          amount: amount,
          period: period,
          startDate: startDate.toIso8601String().split('T')[0],
        );
        _budgets.add(Budget.fromJson(newBudget));
        notifyListeners();
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<void> updateBudget(Budget updatedBudget) async {
    try {
      if (_authProvider.token != null) {
        await _budgetApi.updateBudget(
          accessToken: _authProvider.token!,
          budgetId: updatedBudget.id,
          categoryId: updatedBudget.categoryId,
          amount: updatedBudget.amount,
          period: updatedBudget.period,
          startDate: updatedBudget.startDate.toIso8601String().split('T')[0],
        );
        final index =
        _budgets.indexWhere((budget) => budget.id == updatedBudget.id);
        if (index != -1) {
          _budgets[index] = updatedBudget;
          notifyListeners();
        }
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<void> deleteBudget(int budgetId) async {
    try {
      if (_authProvider.token != null) {
        await _budgetApi.deleteBudget(
          accessToken: _authProvider.token!,
          budgetId: budgetId,
        );
        _budgets.removeWhere((budget) => budget.id == budgetId);
        notifyListeners();
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }
}