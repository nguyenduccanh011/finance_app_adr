import 'package:flutter/cupertino.dart';

class BudgetHeader extends StatefulWidget {
  const BudgetHeader({Key? key}) : super(key: key);

  @override
  State<BudgetHeader> createState() => _BudgetHeaderState();
}

class _BudgetHeaderState extends State<BudgetHeader> {
  String _selectedPeriod = "Tháng này"; // Giá trị mặc định

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Tháng này", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Thay "Tháng này" bằng _selectedPeriod nếu muốn hiển thị giá trị được chọn
        // Để đơn giản, bạn có thể dùng TextButton hoặc InkWell để giả lập chọn period
        // Khi có chức năng chọn period thực tế, bạn sẽ thay thế bằng DropdownButtonFormField
        // TextButton(
        //   onPressed: () {
        //     // Hiển thị dialog hoặc bottom sheet để chọn period
        //   },
        //   child: Text(_selectedPeriod),
        // ),
      ],
    );
  }
}