import 'api_client.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<dynamic> register({required String username, required String password, required String email}) {
    final body = {
      'username': username,
      'password': password,
      'email': email,
    };
    print('Register request body: $body'); // In ra body
    return _apiClient.post(
      '/auth/register',
      body: body,
    );
  }

  Future<dynamic> login({required String username, required String password}) {
    return _apiClient.post(
      '/auth/login',
      body: {
        'username': username,
        'password': password,
      },
    );
  }
}
