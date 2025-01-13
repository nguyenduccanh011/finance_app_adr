import 'package:http/http.dart' as http;
import 'api_client.dart';

class TransactionApi {
  final ApiClient _apiClient;

  TransactionApi(this._apiClient);

  Future<List<dynamic>> getTransactions({
    required String accessToken,
    int? accountId,
    int? categoryId,
    String? startDate,
    String? endDate,
  }) {
    Map<String, dynamic> queryParameters = {};
    if (accountId != null) {
      queryParameters['accountId'] = accountId.toString();
    }
    if (categoryId != null) {
      queryParameters['categoryId'] = categoryId.toString();
    }
    if (startDate != null) {
      queryParameters['startDate'] = startDate;
    }
    if (endDate != null) {
      queryParameters['endDate'] = endDate;
    }

    return _apiClient.get(
      '/transactions',
      headers: {'Authorization': 'Bearer $accessToken'},
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> createTransaction({
    required String accessToken,
    required int accountId,
    required int categoryId,
    required double amount,
    String? description,
    required String transactionDate,
  }) {
    return _apiClient.post(
      '/transactions',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'account_id': accountId,
        'category_id': categoryId,
        'amount': amount,
        'description': description,
        'transaction_date': transactionDate,
      },
    );
  }

  Future<dynamic> getTransaction(
      {required String accessToken, required int transactionId}) {
    return _apiClient.get(
      '/transactions/$transactionId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> updateTransaction({
    required String accessToken,
    required int transactionId,
    required int accountId,
    required int categoryId,
    required double amount,
    String? description,
    required String transactionDate,
  }) {
    return _apiClient.put(
      '/transactions/$transactionId',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'account_id': accountId,
        'category_id': categoryId,
        'amount': amount,
        'description': description,
        'transaction_date': transactionDate,
      },
    );
  }

  Future<dynamic> deleteTransaction(
      {required String accessToken, required int transactionId}) {
    return _apiClient.delete(
      '/transactions/$transactionId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<Map<String, dynamic>> processImage({
    required String accessToken,
    required List<int> imageBytes, // Thay đổi kiểu dữ liệu ở đây
    required String fileName,
  }) async {
    final file = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: fileName,
    );

    final response = await _apiClient.postMultipart(
      '/transactions/image',
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      },
      fields: {}, // Thêm các trường bổ sung nếu cần
      files: [file],
    );
    return response;
  }
}
