class RecurringTransaction {
  final int id;
  final int userId;
  final int accountId;
  final int categoryId;
  final double amount;
  final String? description;
  final String type;
  final String frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextOccurrence;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? accountName;
  String? categoryName;

  RecurringTransaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    this.description,
    required this.type,
    required this.frequency,
    required this.interval,
    required this.startDate,
    this.endDate,
    required this.nextOccurrence,
    required this.createdAt,
    required this.updatedAt,
    this.accountName,
    this.categoryName
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
        id: json['id'],
        userId: json['user_id'],
        accountId: json['account_id'],
        categoryId: json['category_id'],
        amount: json['amount'].toDouble(),
        description: json['description'],
        type: json['type'],
        frequency: json['frequency'],
        interval: json['interval'],
        startDate: DateTime.parse(json['start_date']),
        endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
        nextOccurrence: DateTime.parse(json['next_occurrence']),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        accountName: json['account_name'] ?? '', // Xử lý null
        categoryName: json['category_name'] ?? '' // Xử lý null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'type': type,
      'frequency': frequency,
      'interval': interval,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'next_occurrence': nextOccurrence.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'account_name': accountName,
      'category_name': categoryName,
    };
  }
}