import 'package:flutter/material.dart';
import '../models/account.dart';
import '../utils/number_utils.dart';

class AccountListItem extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;

  const AccountListItem({
    Key? key,
    required this.account,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Thêm margin
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: _getAccountIcon(account.name),
          title: Text(
            account.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            NumberUtils.formatCurrency(account.balance),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _getAccountIcon(String accountName) {
    switch (accountName) {
      case 'ACB':
        return Image.asset('assets/icons/acb_icon.png', width: 40, height: 40,); // Thay 'path/to/acb_icon.png' bằng đường dẫn thật
      case 'VCB':
        return Image.asset('assets/icons/vcb_icon.png', width: 40, height: 40,); // Thay 'path/to/vcb_icon.png' bằng đường dẫn thật
      case 'Tiền mặt':
        return Icon(Icons.money, size: 40,);
      default:
        return Icon(Icons.account_balance, size: 40,);
    }
  }
}