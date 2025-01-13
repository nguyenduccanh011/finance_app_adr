import 'package:flutter/foundation.dart';
import '../api/recurring_transaction_api.dart';
import '../models/recurring_transaction.dart';
import 'auth_provider.dart';

class RecurringTransactionProvider with ChangeNotifier {
  final RecurringTransactionApi _recurringTransactionApi;
  final AuthProvider _authProvider;
  List<RecurringTransaction> _recurringTransactions = [];

  RecurringTransactionProvider(
      this._recurringTransactionApi, this._authProvider) {
    if (_authProvider.isAuthenticated) {
      fetchRecurringTransactions();
    }
  }

  List<RecurringTransaction> get recurringTransactions =>
      _recurringTransactions;

  Future<void> fetchRecurringTransactions() async {
    try {
      if (_authProvider.token != null) {
        final data = await _recurringTransactionApi.getRecurringTransactions(
          accessToken: _authProvider.token!,
        );
        if (data is List) {
          _recurringTransactions = data
              .map<RecurringTransaction>(
                  (json) => RecurringTransaction.fromJson(json))
              .toList();
        } else {
          throw Exception(
              "Expected a list of recurring transactions but received: ${data.runtimeType}");
        }
        notifyListeners();
      } else {
        print('Token is null. Cannot fetch recurring transactions.');
      }
    } catch (error) {
      print("Error fetching recurring transactions: $error");
      rethrow;
    }
  }

  Future<RecurringTransaction?> getRecurringTransaction(
      int recurringTransactionId) async {
    try {
      final response =
      await _recurringTransactionApi.getRecurringTransaction(
        accessToken: _authProvider.token!,
        recurringTransactionId: recurringTransactionId,
      );
      if (response is Map<String, dynamic> && response.containsKey('id')) {
        return RecurringTransaction.fromJson(response);
      } else {
        print('Recurring transaction not found or invalid response format');
        return null;
      }
    } catch (error) {
      print('Error getting recurring transaction: $error');
      return null;
    }
  }

  Future<void> createRecurringTransaction(
      RecurringTransaction recurringTransaction) async {
    try {
      final newRecurringTransaction =
      await _recurringTransactionApi.createRecurringTransaction(
        accessToken: _authProvider.token!,
        accountId: recurringTransaction.accountId,
        categoryId: recurringTransaction.categoryId,
        amount: recurringTransaction.amount,
        description: recurringTransaction.description,
        type: recurringTransaction.type,
        frequency: recurringTransaction.frequency,
        interval: recurringTransaction.interval,
        startDate: recurringTransaction.startDate,
        endDate: recurringTransaction.endDate,
      );
      _recurringTransactions
          .add(RecurringTransaction.fromJson(newRecurringTransaction));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateRecurringTransaction(
      RecurringTransaction updatedRecurringTransaction) async {
    try {
      await _recurringTransactionApi.updateRecurringTransaction(
        accessToken: _authProvider.token!,
        recurringTransactionId: updatedRecurringTransaction.id,
        recurringTransaction: updatedRecurringTransaction,
      );
      final index = _recurringTransactions.indexWhere(
              (recurringTransaction) =>
          recurringTransaction.id == updatedRecurringTransaction.id);
      if (index != -1) {
        _recurringTransactions[index] = updatedRecurringTransaction;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteRecurringTransaction(int recurringTransactionId) async {
    try {
      await _recurringTransactionApi.deleteRecurringTransaction(
        accessToken: _authProvider.token!,
        recurringTransactionId: recurringTransactionId,
      );
      _recurringTransactions.removeWhere((recurringTransaction) =>
      recurringTransaction.id == recurringTransactionId);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}