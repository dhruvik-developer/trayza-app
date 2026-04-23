import 'dart:math' as math;

import 'order_model.dart';

class InvoiceModel {
  final String billNo;
  final String paymentMode;
  final String paymentStatus;
  final double advanceAmount;
  final double pendingAmount;
  final double transactionAmount;
  final double settlementAmount;
  final double totalAmount;
  final double totalExtraAmount;
  final String? formattedEventDate;
  final OrderModel booking;
  final Map<String, dynamic> rawData;

  const InvoiceModel({
    required this.billNo,
    required this.paymentMode,
    required this.paymentStatus,
    required this.advanceAmount,
    required this.pendingAmount,
    required this.transactionAmount,
    required this.settlementAmount,
    required this.totalAmount,
    required this.totalExtraAmount,
    required this.booking,
    required this.rawData,
    this.formattedEventDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final bookingJson =
        Map<String, dynamic>.from(json['booking'] as Map? ?? const {});

    return InvoiceModel(
      billNo: json['bill_no']?.toString() ??
          json['id']?.toString() ??
          bookingJson['id']?.toString() ??
          '',
      paymentMode: json['payment_mode']?.toString() ?? 'CASH',
      paymentStatus: json['payment_status']?.toString() ?? 'UNPAID',
      advanceAmount: _toDouble(json['advance_amount']),
      pendingAmount: _toDouble(json['pending_amount']),
      transactionAmount: _toDouble(json['transaction_amount']),
      settlementAmount: _toDouble(json['settlement_amount']),
      totalAmount: _toDouble(json['total_amount']),
      totalExtraAmount: _toDouble(json['total_extra_amount']),
      formattedEventDate: json['formatted_event_date']?.toString(),
      booking: OrderModel.fromJson(bookingJson),
      rawData: Map<String, dynamic>.from(json),
    );
  }

  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';

  double get displayPendingAmount => isPaid
      ? 0
      : math.max(
          0,
          pendingAmount > 0
              ? pendingAmount
              : totalAmount -
                  advanceAmount -
                  transactionAmount -
                  settlementAmount,
        );

  String get eventDateSummary {
    final bookingDates = booking.formattedEventDateSummary;
    if (bookingDates != '—') return bookingDates;

    final fallbackDate = formattedEventDate?.trim();
    return fallbackDate == null || fallbackDate.isEmpty ? '—' : fallbackDate;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
