import 'package:flutter/material.dart';
import 'package:tesst_app/screens/accounts/transfer_screen.dart';
import 'models/account.dart';
import 'models/budget.dart';
import 'models/recurring_transaction.dart';
import 'models/transaction.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/accounts/accounts_screen.dart';
import 'screens/accounts/add_edit_account_screen.dart';
import 'screens/accounts/account_details_screen.dart';
import 'screens/budgets/budgets_screen.dart';
import 'screens/budgets/add_edit_budget_screen.dart';
import 'screens/budgets/budget_details_screen.dart';
import 'screens/categories/categories_manager_screen.dart';
import 'screens/categories/add_edit_category_screen.dart';
import 'screens/transactions/add_transaction_screen.dart';
import 'screens/transactions/add_transaction_from_image_screen.dart';
import 'screens/transactions/edit_transaction_screen.dart';
import 'screens/transactions/transaction_details_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/recurring_transactions/recurring_transactions_screen.dart'; // Import màn hình danh sách
import 'screens/recurring_transactions/add_edit_recurring_transaction_screen.dart'; // Import màn hình thêm/sửa
import 'screens/transactions/transactions_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String accounts = '/accounts';
  static const String addAccount = '/add-edit-account';
  static const String accountDetails = '/account-details';
  static const String budgets = '/budgets';
  static const String addBudget = '/add-edit-budget';
  static const String budgetDetails = '/budget-details';
  static const String categories = '/categories-manager';
  static const String addCategory = '/add-edit-category';
  static const String addTransaction = '/add-transaction';
  static const String addTransactionFromImage = '/add-transaction-from-image';
  static const String editTransaction = '/edit-transaction';
  static const String transactionDetails = '/transaction-details';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String recurringTransactions = '/recurring-transactions';
  static const String addEditRecurringTransaction = '/add-edit-recurring-transaction';
  static const String transactions = '/transactions-list';
  static const String transfer = '/transfer';


  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    accounts: (context) => const AccountsScreen(),
    // Sửa route addAccount
    addAccount: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      final account = args is Account ? args : null; // Trích xuất account từ arguments
      return AddEditAccountScreen(account: account); // Truyền account vào constructor
    },
    accountDetails: (context) {
      final account = ModalRoute.of(context)!.settings.arguments as Account;
      return AccountDetailsScreen(account: account);
    },
    budgets: (context) => const BudgetsScreen(),
    addBudget: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      final budget = args is Budget ? args : null;
      return AddEditBudgetScreen(budget: budget);
    },
    budgetDetails: (context) {
      final budget =
      ModalRoute.of(context)!.settings.arguments as Budget; // Nhận budget object
      return BudgetDetailsScreen(budget: budget); // Truyền budget vào constructor
    },
    categories: (context) => const CategoriesManagerScreen(),
    addCategory: (context) => const AddEditCategoryScreen(),
    addTransaction: (context) => const AddTransactionScreen(),
    addTransactionFromImage: (context) => AddTransactionFromImageScreen(),
    editTransaction: (context) {
      final transactionId = ModalRoute.of(context)!.settings.arguments as int;
      return EditTransactionScreen(transactionId: transactionId);
    },
    transactionDetails: (context) {
      final transaction =
      ModalRoute.of(context)!.settings.arguments as Transaction; // Nhận transaction object
      return TransactionDetailsScreen(transaction: transaction); // Truyền transaction vào constructor
    },
    reports: (context) => const ReportsScreen(),
    settings: (context) => const SettingsScreen(),
    // Sửa routes cho Recurring Transactions
    recurringTransactions: (context) => const RecurringTransactionsScreen(),
    addEditRecurringTransaction: (context) {
      final recurringTransaction = ModalRoute.of(context)!.settings.arguments as RecurringTransaction?;
      return AddEditRecurringTransactionScreen(
          recurringTransaction: recurringTransaction);
    },
    transactions: (context) => const TransactionsScreen(),
    transfer: (context) => const TransferScreen(),
  };
}