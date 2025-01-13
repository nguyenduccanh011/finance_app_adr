import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../models/account.dart'; // Thêm import này
import '../../utils/number_utils.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Account account;

  const AccountDetailsScreen({Key? key, required this.account})
      : super(key: key);

  @override
  _AccountDetailsScreenState createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết tài khoản'),
        ),
        drawer: const CustomDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Tên: ${widget.account.name}',
                  style: const TextStyle(fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Số dư: ${NumberUtils.formatCurrency(widget.account.balance)}',
                  style: const TextStyle(fontSize: 18)),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Giao dịch',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<Transaction>>(
              future: Provider.of<TransactionProvider>(context, listen: false)
                  .fetchTransactionsByAccountId(widget.account.id),
              builder: (context, transactionsSnapshot) {
                if (transactionsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (transactionsSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${transactionsSnapshot.error}'));
                } else if (!transactionsSnapshot.hasData ||
                    transactionsSnapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No transactions found.'));
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: transactionsSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final transaction =
                        transactionsSnapshot.data![index];
                        return ListTile(
                          title: Text(transaction.description ?? 'N/A'),
                          subtitle: Text(DateFormat('dd/MM/yyyy')
                              .format(transaction.transactionDate)),
                          trailing: Text(
                            NumberUtils.formatCurrency(transaction.amount),
                            style: TextStyle(
                              color: transaction.amount < 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}