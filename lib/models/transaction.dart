class Transaction {
  final int id;
  final int accountId;
  final int categoryId;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? categoryName;
  String? accountName;

  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.accountName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        id: json['id'],
        accountId: json['account_id'],
        categoryId: json['category_id'],
        amount: json['amount'].toDouble(),
        description: json['description'],
        transactionDate: DateTime.parse(json['transaction_date']),
        imageUrl: json['image_url'],
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
        categoryName: json['category_name'],
        accountName: json['account_name']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'transaction_date':
          transactionDate.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category_name': categoryName,
      'account_name': accountName,
    };
  }
}
