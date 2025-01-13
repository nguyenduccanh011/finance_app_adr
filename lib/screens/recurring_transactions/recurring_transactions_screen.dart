import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recurring_transaction_provider.dart';
import '../../routes.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/recurring_transaction_tist_item.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({Key? key}) : super(key: key);

  @override
  _RecurringTransactionsScreenState createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecurringTransactions();
  }

  Future<void> _loadRecurringTransactions() async {
    await Provider.of<RecurringTransactionProvider>(context, listen: false)
        .fetchRecurringTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch định kỳ'),
      ),
      drawer: const CustomDrawer(),
      body: Consumer<RecurringTransactionProvider>(
        builder: (context, recurringTransactionProvider, child) {
          if (recurringTransactionProvider.recurringTransactions.isEmpty) {
            return const Center(child: Text("Không có giao dịch định kỳ nào."));
          }
          return RefreshIndicator(
            onRefresh: _loadRecurringTransactions,
            child: ListView.builder(
              itemCount:
              recurringTransactionProvider.recurringTransactions.length,
              itemBuilder: (context, index) {
                final recurringTransaction =
                recurringTransactionProvider.recurringTransactions[index];
                return RecurringTransactionListItem(
                  recurringTransaction: recurringTransaction,
                  onTap: () {
                    //  Navigator.pushNamed(
                    //  context,
                    //   Routes.recurringTransactionDetails,
                    //   arguments: recurringTransaction,
                    // );
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      Routes.addEditRecurringTransaction,
                      arguments: recurringTransaction, // Truyền recurringTransaction object
                    ).then((value) {
                      if (value == true) {
                        _loadRecurringTransactions();
                      }
                    });
                  },
                  onDelete: () {
                    _showDeleteConfirmationDialog(
                        context, recurringTransaction.id);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addEditRecurringTransaction)
              .then((value) {
            if (value == true) {
              _loadRecurringTransactions();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, int recurringTransactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch định kỳ?'),
        content:
        const Text('Bạn có chắc chắn muốn xóa giao dịch định kỳ này?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Không'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Có'),
            onPressed: () {
              Provider.of<RecurringTransactionProvider>(context, listen: false)
                  .deleteRecurringTransaction(recurringTransactionId)
                  .then((_) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Đã xóa giao dịch định kỳ')),
                );
              }).catchError((error) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa thất bại: $error')),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}