import 'package:flutter/foundation.dart';
import 'package:tesst_app/api/api_client.dart';
import 'package:tesst_app/models/account.dart';
import 'package:tesst_app/models/category.dart';
import 'package:tesst_app/providers/account_provider.dart';

import '../api/transaction_api.dart';
import '../models/transaction.dart';
import 'auth_provider.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionApi _transactionApi;
  final AuthProvider _authProvider;
  final AccountProvider _accountProvider; // Thêm AccountProvider
  List<Transaction> _transactions = [];

  TransactionProvider(this._transactionApi, this._authProvider, this._accountProvider){ // Sửa constructor
    if (_authProvider.isAuthenticated) {
      fetchTransactions();
    }
  }

  List<Transaction> get transactions => _transactions;

  Future<void> fetchTransactions(
      {int? accountId, int? categoryId, String? startDate, String? endDate}) async {
    try {
      if (_authProvider.token != null) {
        final data = await _transactionApi.getTransactions(
          accessToken: _authProvider.token!,
          accountId: accountId,
          categoryId: categoryId,
          startDate: startDate,
          endDate: endDate,
        );
        if (data is List) {
          _transactions =
              data.map<Transaction>((json) => Transaction.fromJson(json)).toList();
          notifyListeners();
        } else {
          throw Exception(
              "Expected a list of transactions but received: ${data.runtimeType}");
        }
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<Transaction> getTransaction(int transactionId) async {
    try {
      if (_authProvider.token != null) {
        final response = await _transactionApi.getTransaction(
          accessToken: _authProvider.token!,
          transactionId: transactionId,
        );
        //Kiểm tra xem response có phải là lỗi từ server không
        if (response is Map && response.containsKey('message')) {
          throw ApiException(response['message']);
        }
        //Nếu không có lỗi, parse transaction từ response
        return Transaction.fromJson(response);
      } else {
        print('Token is null. Cannot get transaction.');
        throw Exception('Authentication required to get transaction.');
      }
    } catch (error) {
      print('Error get transaction: $error');
      rethrow;
    }
  }

  Future<void> createTransaction(
      {required int accountId,
        required int categoryId,
        required double amount,
        String? description,
        required DateTime transactionDate}) async {
    try {
      if (_authProvider.token != null) {
        final newTransaction = await _transactionApi.createTransaction(
          accessToken: _authProvider.token!,
          accountId: accountId,
          categoryId: categoryId,
          amount: amount,
          description: description,
          transactionDate: transactionDate.toIso8601String().split('T')[0],
        );
        _transactions.add(Transaction.fromJson(newTransaction));
        notifyListeners();
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<void> createTransactionFromImage({
    required String accessToken,
    required List<int> imageBytes,
    required String fileName,
    required int accountId,
    required int categoryId,
    required double amount,
    String? description,
    required DateTime transactionDate,
  }) async {
    try {
      if (_authProvider.token != null) {
        // Gọi API xử lý hình ảnh để lấy thông tin giao dịch
        final imageData = await _transactionApi.processImage(
          accessToken: accessToken,
          imageBytes: imageBytes,
          fileName: fileName,
        );

        // Tạo giao dịch mới từ thông tin đã xử lý
        final newTransaction = await _transactionApi.createTransaction(
          accessToken: _authProvider.token!,
          accountId: accountId,
          categoryId: categoryId,
          amount: amount,
          description: description,
          transactionDate: transactionDate.toIso8601String().split('T')[0],
        );
        _transactions.add(Transaction.fromJson(newTransaction));
        notifyListeners();
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      if (_authProvider.token != null) {
        await _transactionApi.updateTransaction(
          accessToken: _authProvider.token!,
          transactionId: updatedTransaction.id,
          accountId: updatedTransaction.accountId,
          categoryId: updatedTransaction.categoryId,
          amount: updatedTransaction.amount,
          description: updatedTransaction.description,
          transactionDate:
          updatedTransaction.transactionDate.toIso8601String().split('T')[0],
        );
        final index = _transactions
            .indexWhere((transaction) => transaction.id == updatedTransaction.id);
        if (index != -1) {
          _transactions[index] = updatedTransaction;
          notifyListeners();
        }
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      if (_authProvider.token != null) {
        final transaction = _transactions.firstWhere((t) => t.id == transactionId);
        final accountId = transaction.accountId;
        final amount = transaction.amount;

        await _transactionApi.deleteTransaction(
          accessToken: _authProvider.token!,
          transactionId: transactionId,
        );

        _transactions.removeWhere((transaction) => transaction.id == transactionId);
        notifyListeners();

        // Cập nhật số dư tài khoản sau khi xóa giao dịch
        _accountProvider.updateBalance(accountId, _accountProvider.accounts.firstWhere((element) => element.id == accountId).balance - amount);
      }
    } catch (error) {
      // Xử lý lỗi
      rethrow;
    }
  }

  Future<List<Transaction>> fetchTransactionsByAccountId(int accountId) async {
    try {
      if (_authProvider.token != null) {
        final data = await _transactionApi.getTransactions(
          accessToken: _authProvider.token!,
          accountId: accountId,
        );
        if (data is List) {
          return data.map<Transaction>((json) => Transaction.fromJson(json)).toList();
        } else {
          throw Exception(
              "Expected a list of transactions but received: ${data.runtimeType}");
        }
      } else {
        print('Token is null. Cannot fetch transactions.');
        throw Exception('Authentication required to fetch transactions.');
      }
    } catch (error) {
      print('Error fetching transactions by account ID: $error');
      rethrow;
    }
  }

  // Thêm hàm này vào TransactionProvider
  void updateTransactionList(Transaction transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    } else {
      _transactions.add(transaction);
    }
    notifyListeners();
  }

// Thêm hàm này vào TransactionProvider
  void removeTransactionFromList(int transactionId) {
    _transactions.removeWhere((t) => t.id == transactionId);
    notifyListeners();
  }

  Future<double> getTotalSpentForCategory(int categoryId) async {
    if (_transactions.isEmpty) {
      await fetchTransactions();
    }

    double totalSpent = 0;
    for (var transaction in _transactions) {
      if (transaction.categoryId == categoryId && transaction.amount < 0) {
        totalSpent += transaction.amount.abs(); // Cộng giá trị tuyệt đối của các khoản chi tiêu
      }
    }

    return totalSpent;
  }

}