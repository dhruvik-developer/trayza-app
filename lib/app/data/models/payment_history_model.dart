class PaymentHistoryModel {
  final double netAmount;
  final double totalPaidAmount;
  final double totalUnpaidAmount;
  final double totalSettlementAmount;
  final double totalExpenseAmount;

  const PaymentHistoryModel({
    required this.netAmount,
    required this.totalPaidAmount,
    required this.totalUnpaidAmount,
    required this.totalSettlementAmount,
    required this.totalExpenseAmount,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      netAmount: _toDouble(json['net_amount']),
      totalPaidAmount: _toDouble(json['total_paid_amount']),
      totalUnpaidAmount: _toDouble(json['total_unpaid_amount']),
      totalSettlementAmount: _toDouble(json['total_settlement_amount']),
      totalExpenseAmount: _toDouble(json['total_expense_amount']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
