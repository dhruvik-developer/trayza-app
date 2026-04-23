class EventAssignmentModel {
  final int id;
  final int? staffId;
  final String staffName;
  final String staffType;
  final String sessionName;
  final String sessionDate;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentStatus;
  final Map<String, dynamic> rawData;

  const EventAssignmentModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffType,
    required this.sessionName,
    required this.sessionDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.rawData,
  });

  factory EventAssignmentModel.fromJson(Map<String, dynamic> json) {
    return EventAssignmentModel(
      id: _toInt(json['id']) ?? 0,
      staffId: _toInt(json['staff']),
      staffName: json['staff_name']?.toString() ?? 'Unknown Staff',
      staffType: json['staff_type']?.toString() ?? 'Unknown',
      sessionName: json['session_name']?.toString() ??
          json['session']?.toString() ??
          'Session',
      sessionDate: json['session_date']?.toString() ?? '—',
      totalAmount: _toDouble(json['total_amount']),
      paidAmount: _toDouble(json['paid_amount']),
      remainingAmount: _toDouble(json['remaining_amount']),
      paymentStatus: json['payment_status']?.toString() ?? 'Pending',
      rawData: Map<String, dynamic>.from(json),
    );
  }

  bool get canAcceptPayment => staffType.toLowerCase() != 'fixed';

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class EventSummaryModel {
  final int? staffId;
  final String staffName;
  final String staffType;
  final double totalAmount;
  final double totalPaid;
  final double totalPending;
  final List<EventAssignmentModel> events;

  const EventSummaryModel({
    required this.staffId,
    required this.staffName,
    required this.staffType,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalPending,
    required this.events,
  });
}
