import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import '../utils/number_utils.dart';

class BudgetProgressIndicator extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final int remainingDays;

  const BudgetProgressIndicator({
    Key? key,
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final remainingBudget = totalBudget - totalSpent;
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;
    //Sử dụng CustomPaint để vẽ hình bán nguyệt
    return Column(
      children: [
        CustomPaint(
          painter: ArcPainter(percentage: percentage),
          child: SizedBox(
            width: 250,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0), // Điều chỉnh padding top
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Đổi mainAxisAlignment
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Số tiền bạn có thể chi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberUtils.formatCurrency(remainingBudget),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('Tổng ngân sách', style: TextStyle(fontSize: 14)),
                Text(NumberUtils.formatCurrency(totalBudget),
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            Column(
              children: [
                const Text('Tổng đã chi', style: TextStyle(fontSize: 14)),
                Text(NumberUtils.formatCurrency(totalSpent),
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            Column(
              children: [
                const Text('Đến cuối tháng', style: TextStyle(fontSize: 14)),
                Text('$remainingDays ngày', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ArcPainter extends CustomPainter {
  final double percentage;

  ArcPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 15 // Tăng độ dày của vòng cung
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Thay đổi center và radius để vẽ nửa dưới vòng tròn
    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height), // Dời tâm xuống cạnh dưới
      width: size.width,
      height: size.height * 1.5, // Tăng height để chứa được bán kính lớn hơn
    );

    // Vẽ phần nền màu xám (nửa dưới)
    paint.color = Colors.grey.shade300;
    canvas.drawArc(
        rect,
        3.14159265359, // Bắt đầu từ 180 độ (pi)
        3.14159265359, // Quét một góc 180 độ (pi)
        false,
        paint);

    // Vẽ phần tiến trình (nửa dưới)
    // Nếu percentage > 1 (vượt quá ngân sách), vẽ cung màu đỏ từ 0 đến pi (nửa cung tròn)
    // Ngược lại, vẽ cung màu xanh dựa trên percentage
    if (percentage > 1) {
      paint.color = Colors.red;
      canvas.drawArc(
          rect,
          3.14159265359,
          3.14159265359,
          false,
          paint
      );
    } else {
      paint.color = AppConstants.primaryColor;
      canvas.drawArc(
          rect,
          3.14159265359, // Bắt đầu từ 180 độ (pi)
          3.14159265359 * (percentage < 0 ? 0 : percentage), // Quét một góc dựa trên percentage, không vượt quá 100%
          false,
          paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}