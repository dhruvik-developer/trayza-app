class OrderModel {
  final int id;
  final String? clientName;
  final String? eventDate;
  final String? eventType;
  final String? status;
  final double? totalAmount;

  OrderModel({
    required this.id,
    this.clientName,
    this.eventDate,
    this.eventType,
    this.status,
    this.totalAmount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      clientName: json['client_name'] ?? json['customer_name'] ?? '',
      eventDate: json['event_date'] ?? '',
      eventType: json['event_type'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
    );
  }
}
