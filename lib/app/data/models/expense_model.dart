class ExpenseModel {
  final int id;
  final String title;
  final dynamic category;
  final String? categoryName;
  final String description;
  final String amount;
  final String paymentMode;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.category,
    this.categoryName,
    required this.description,
    required this.amount,
    required this.paymentMode,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'],
      categoryName: json['category_name'],
      description: json['description'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      paymentMode: json['payment_mode'] ?? 'CASH',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'amount': amount,
      'payment_mode': paymentMode,
    };
  }
}
