import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'api/api_client.dart';
import 'api/auth_api.dart';
import 'api/account_api.dart';
import 'api/category_api.dart';
import 'api/transaction_api.dart';
import 'api/budget_api.dart';
import 'api/recurring_transaction_api.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/category_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/recurring_transaction_provider.dart';
import 'utils/app_constants.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient(baseUrl: AppConstants.apiBaseUrl);
  final authApi = AuthApi(apiClient);
  final accountApi = AccountApi(apiClient);
  final categoryApi = CategoryApi(apiClient);
  final transactionApi = TransactionApi(apiClient);
  final budgetApi = BudgetApi(apiClient);
  final recurringTransactionApi = RecurringTransactionApi(apiClient);

  final authProvider = AuthProvider(authApi);
  await authProvider.loadUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => authProvider,
        ),
        ChangeNotifierProxyProvider<AuthProvider, AccountProvider>(
          create: (context) => AccountProvider(
              accountApi, Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previousAccounts) =>
          auth.isAuthenticated
              ? AccountProvider(accountApi, auth)
              : previousAccounts ?? AccountProvider(accountApi, auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CategoryProvider>(
          create: (context) => CategoryProvider(
              categoryApi, Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previousCategories) =>
          auth.isAuthenticated
              ? CategoryProvider(categoryApi, auth)
              : previousCategories ?? CategoryProvider(categoryApi, auth),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, AccountProvider, TransactionProvider>(
          create: (context) => TransactionProvider(
            transactionApi,
            Provider.of<AuthProvider>(context, listen: false),
            Provider.of<AccountProvider>(context, listen: false),
          ),
          update: (context, auth, account, previousTransactions) =>
          auth.isAuthenticated
              ? TransactionProvider(transactionApi, auth, account)
              : previousTransactions ??
              TransactionProvider(transactionApi, auth, account),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BudgetProvider>(
          create: (context) => BudgetProvider(
              budgetApi, Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previousBudgets) =>
          auth.isAuthenticated
              ? BudgetProvider(budgetApi, auth)
              : previousBudgets ?? BudgetProvider(budgetApi, auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RecurringTransactionProvider>(
          create: (context) => RecurringTransactionProvider(
              recurringTransactionApi, Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previousRecurringTransactions) =>
          auth.isAuthenticated
              ? RecurringTransactionProvider(recurringTransactionApi, auth)
              : previousRecurringTransactions ?? RecurringTransactionProvider(recurringTransactionApi, auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
