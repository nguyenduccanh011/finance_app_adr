import 'package:tesst_app/models/recurring_transaction.dart';
import 'api_client.dart';

class RecurringTransactionApi {
  final ApiClient _apiClient;

  RecurringTransactionApi(this._apiClient);

  Future<List<dynamic>> getRecurringTransactions({required String accessToken}) {
    return _apiClient.get(
      '/recurring-transactions',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> createRecurringTransaction({
    required String accessToken,
    required int accountId,
    required int categoryId,
    required double amount,
    String? description,
    required String type,
    required String frequency,
    required int interval,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    return _apiClient.post(
      '/recurring-transactions',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'account_id': accountId,
        'category_id': categoryId,
        'amount': amount,
        'description': description,
        'type': type,
        'frequency': frequency,
        'interval': interval,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate?.toIso8601String().split('T')[0],
      },
    );
  }

  Future<dynamic> getRecurringTransaction(
      {required String accessToken, required int recurringTransactionId}) {
    return _apiClient.get(
      '/recurring-transactions/$recurringTransactionId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> updateRecurringTransaction({
    required String accessToken,
    required int recurringTransactionId,
    required RecurringTransaction recurringTransaction,
  }) {
    return _apiClient.put(
      '/recurring-transactions/$recurringTransactionId',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: recurringTransaction.toJson(),
    );
  }

  Future<dynamic> deleteRecurringTransaction({
    required String accessToken,
    required int recurringTransactionId,
  }) {
    return _apiClient.delete(
      '/recurring-transactions/$recurringTransactionId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
