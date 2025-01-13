import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi;
  User? _user;
  String? _token;

  AuthProvider(this._authApi);

  User? get user => _user;
  String? get token => _token;

  bool get isAuthenticated => _user != null && _token != null;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    print('Token loaded from SharedPreferences: $_token'); // In ra để debug

    if (_token != null) {
      // Load user info from shared preferences if available
      final userId = prefs.getInt('userId');
      final userName = prefs.getString('userName');
      final userEmail = prefs.getString('userEmail');

      if (userId != null && userName != null && userEmail != null) {
        _user = User(id: userId, username: userName, email: userEmail, accessToken: _token);
      }
    }
    notifyListeners();
  }

  Future<void> register({required String username, required String password, required String email}) async {
    try {
      final response = await _authApi.register(username: username, password: password, email: email);
      // Xử lý response (nếu cần)
      print('Register response: $response'); // In ra response
      // Đăng nhập luôn sau khi đăng ký thành công
      await login(username: username, password: password);
      notifyListeners();
    } catch (e) {
      // Xử lý lỗi
      print('Error during registration: $e'); // In lỗi ra console (quan trọng)
      if (e is ApiException) {
        print('API Exception details: ${e.toString()}');
      }
      rethrow;
    }
  }

  Future<void> login({required String username, required String password}) async {
    try {
      final response = await _authApi.login(username: username, password: password);

      // In ra response để kiểm tra
      print('Login response: $response');

      _token = response['token'];
      _user = User.fromJson(response['user']);

      // In ra token và user
      print('Token: $_token');
      print('User: ${_user?.toJson()}');

      // Lưu thông tin user và token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setInt('userId', _user!.id);
      await prefs.setString('userName', _user!.username);
      await prefs.setString('userEmail', _user!.email);

      notifyListeners();
    } catch (e) {
      // Xử lý lỗi
      print('Error during login: $e'); // In ra lỗi
      _user = null;
      _token = null;
      rethrow;
    }
  }

  Future<void> logout() async {
    // Xóa token và user khỏi SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');

    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');

    _user = null;
    _token = null;
    notifyListeners();
  }
}