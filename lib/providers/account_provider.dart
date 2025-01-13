import 'package:flutter/foundation.dart';
import '../api/account_api.dart';
import '../models/account.dart';
import 'auth_provider.dart';

class AccountProvider with ChangeNotifier {
  final AccountApi _accountApi;
  final AuthProvider _authProvider;
  List<Account> _accounts = [];

  AccountProvider(this._accountApi, this._authProvider) {
    // Di chuyển fetchAccounts() vào đây
    if (_authProvider.isAuthenticated) {
      fetchAccounts();
    }
  }

  List<Account> get accounts => _accounts;

  // Thêm kiểm tra _authProvider.token != null
  Future<void> fetchAccounts() async {
    try {
      if (_authProvider.token != null) {
        final data =
        await _accountApi.getAccounts(accessToken: _authProvider.token!);
        if (data is List) {
          _accounts =
              data.map<Account>((json) => Account.fromJson(json)).toList();
        } else {
          throw Exception(
              "Expected a list of accounts but received: ${data.runtimeType}");
        }
        notifyListeners();
      } else {
        print('Token is null. Cannot fetch accounts.');
        // throw Exception('Authentication required to fetch accounts.'); // Có thể throw exception nếu cần
      }
    } catch (error) {
      // Xử lý lỗi
      print("Error fetching accounts: $error");
      rethrow;
    }
  }

  Future<Account?> getAccount(int accountId) async {
    try {
      final response = await _accountApi.getAccount(
        accessToken: _authProvider.token!,
        accountId: accountId,
      );
      // Kiểm tra response có hợp lệ không
      if (response is Map<String, dynamic> && response.containsKey('id')) {
        final account = Account.fromJson(response);
        print('Account after fromJson: $account');
        return account;
      } else {
        print('Account not found or invalid response format');
        return null;
      }
    } catch (error) {
      print('Error getting account: $error');
      return null; // Xử lý lỗi bằng cách trả về null
    }
  }

  Future<void> createAccount(String name, double balance) async {
    try {
      final newAccount = await _accountApi.createAccount(
        accessToken: _authProvider.token!,
        name: name,
        balance: balance,
      );
      _accounts.add(Account.fromJson(newAccount));
      notifyListeners();
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<void> updateAccount(Account updatedAccount) async {
    try {
      await _accountApi.updateAccount(
        accessToken: _authProvider.token!,
        accountId: updatedAccount.id,
        account: updatedAccount,
      );
      final index =
      _accounts.indexWhere((account) => account.id == updatedAccount.id);
      if (index != -1) {
        _accounts[index] = updatedAccount;
        notifyListeners();
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<void> deleteAccount(int accountId) async {
     try {
      // Lấy danh sách account hiện tại
      final currentAccounts = List<Account>.from(_accounts); // Tạo bản sao

      // Kiểm tra số lượng account
      if (currentAccounts.length <= 1) {
       throw Exception('Không thể xóa tài khoản cuối cùng.');
      }

      // Xóa account
      await _accountApi.deleteAccount(
       accessToken: _authProvider.token!,
       accountId: accountId,
      );
      _accounts.removeWhere((account) => account.id == accountId);
      notifyListeners();
     } catch (error) {
      // Xử lý lỗi
      rethrow;
     }
  }

  double get totalBalance {
    return _accounts.fold(0, (sum, account) => sum + account.balance);
  }

  // Thêm hàm này vào AccountProvider thay vì updateAccountBalance
  Future<void> updateBalance(int accountId, double newBalance) async {
    try {
      final index = _accounts.indexWhere((acc) => acc.id == accountId);
      if (index != -1) {
        // Tạo một đối tượng Account mới với balance đã cập nhật
        final updatedAccount = Account(
          id: _accounts[index].id,
          userId: _accounts[index].userId,
          name: _accounts[index].name,
          balance: newBalance,
          createdAt: _accounts[index].createdAt,
          updatedAt: DateTime.now(),
        );

        // Cập nhật thông tin account trên server
        await _accountApi.updateAccount(
          accessToken: _authProvider.token!,
          accountId: accountId,
          account: updatedAccount,
        );

        // Cập nhật danh sách _accounts trong provider
        _accounts[index] = updatedAccount;
        notifyListeners();
      }
    } catch (error) {
      print('Error updating account balance: $error');
      rethrow;
    }
  }
}