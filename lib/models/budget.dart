class Budget {
  final int id;
  final int categoryId;
  final double amount;
  final String period;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? categoryName;

  Budget(
      {required this.id,
      required this.categoryId,
      required this.amount,
      required this.period,
      required this.startDate,
      required this.createdAt,
      required this.updatedAt,
      this.categoryName});

  factory Budget.fromJson(Map<String, dynamic> json) {
    print('fromJson - json: $json');
    print('fromJson - id: ${json['id']}');
    print('fromJson - category_id: ${json['category_id']}');
    print('fromJson - amount: ${json['amount']}');
    print('fromJson - period: ${json['period']}');
    print('fromJson - start_date: ${json['start_date']}');
    print('fromJson - created_at: ${json['created_at']}');
    print('fromJson - updated_at: ${json['updated_at']}');
    print('fromJson - category_name: ${json['category_name']}');

    try {
      return Budget(
        id: json['id'] as int,
        categoryId: json['category_id'] as int,
        // Sửa lại phần amount
        amount: json['amount'] is num ? (json['amount'] as num).toDouble() : double.tryParse(json['amount'].toString()) ?? 0.0,
        period: json['period'] as String,
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : DateTime.now(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        categoryName: json['category_name'] as String?,
      );
    } catch (e) {
      print('Error in Budget.fromJson: $e');
      rethrow; // Ném lại lỗi để FutureBuilder bắt được
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'period': period,
      'start_date':
          startDate.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category_name': categoryName
    };
  }
}
