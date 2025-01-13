import 'package:tesst_app/models/account.dart';
import 'api_client.dart';

class AccountApi {
  final ApiClient _apiClient;

  AccountApi(this._apiClient);

  Future<List<dynamic>> getAccounts({required String accessToken}) {
    return _apiClient.get(
      '/accounts',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> createAccount(
      {required String accessToken,
      required String name,
      required double balance}) {
    return _apiClient.post(
      '/accounts',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'name': name, 'balance': balance},
    );
  }

  Future<dynamic> getAccount(
      {required String accessToken, required int accountId}) {
    return _apiClient.get(
      '/accounts/$accountId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> updateAccount(
      {required String accessToken,
      required int accountId,
      required Account account}) {
    return _apiClient.put(
      '/accounts/$accountId',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: account.toJson(),
    );
  }

  Future<dynamic> deleteAccount(
      {required String accessToken, required int accountId}) {
    return _apiClient.delete(
      '/accounts/$accountId',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
