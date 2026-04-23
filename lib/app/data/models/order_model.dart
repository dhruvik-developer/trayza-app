import 'package:intl/intl.dart';

class OrderSessionModel {
  final int? id;
  final String? eventDate;
  final String? eventTime;
  final int estimatedPersons;
  final double perDishAmount;
  final double extraServiceAmount;
  final double waiterServiceAmount;
  final List<Map<String, dynamic>> extraService;
  final Map<String, dynamic> rawData;

  const OrderSessionModel({
    this.id,
    this.eventDate,
    this.eventTime,
    required this.estimatedPersons,
    required this.perDishAmount,
    required this.extraServiceAmount,
    required this.waiterServiceAmount,
    required this.extraService,
    required this.rawData,
  });

  factory OrderSessionModel.fromJson(Map<String, dynamic> json) {
    final extra = (json['extra_service'] as List?)
            ?.whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList() ??
        const <Map<String, dynamic>>[];

    return OrderSessionModel(
      id: _toInt(json['id']),
      eventDate: json['event_date']?.toString(),
      eventTime: json['event_time']?.toString(),
      estimatedPersons: _toInt(json['estimated_persons']) ?? 0,
      perDishAmount: _toDouble(json['per_dish_amount']),
      extraServiceAmount: _toDouble(json['extra_service_amount']),
      waiterServiceAmount: _toDouble(json['waiter_service_amount']),
      extraService: extra,
      rawData: Map<String, dynamic>.from(json),
    );
  }

  factory OrderSessionModel.fallbackFromOrder(OrderModel order) {
    return OrderSessionModel(
      id: null,
      eventDate: order.eventDate,
      eventTime: order.eventTime,
      estimatedPersons: order.estimatedPersons,
      perDishAmount: order.perDishAmount,
      extraServiceAmount: order.extraServiceAmount,
      waiterServiceAmount: order.waiterServiceAmount,
      extraService: const <Map<String, dynamic>>[],
      rawData: Map<String, dynamic>.from(order.rawData),
    );
  }

  double get totalDishAmount => perDishAmount * estimatedPersons;

  double get totalAmount =>
      totalDishAmount + extraServiceAmount + waiterServiceAmount;

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

class OrderModel {
  final int id;
  final String name;
  final String? reference;
  final String? mobileNo;
  final String? status;
  final String? eventDate;
  final String? eventTime;
  final int estimatedPersons;
  final double perDishAmount;
  final double extraServiceAmount;
  final double waiterServiceAmount;
  final double advanceAmount;
  final String? eventAddress;
  final List<OrderSessionModel> sessions;
  final Map<String, dynamic> rawData;

  const OrderModel({
    required this.id,
    required this.name,
    this.reference,
    this.mobileNo,
    this.status,
    this.eventDate,
    this.eventTime,
    required this.estimatedPersons,
    required this.perDishAmount,
    required this.extraServiceAmount,
    required this.waiterServiceAmount,
    required this.advanceAmount,
    this.eventAddress,
    required this.sessions,
    required this.rawData,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final sessionList = (json['sessions'] as List?)
            ?.whereType<Map>()
            .map((item) => OrderSessionModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList() ??
        const <OrderSessionModel>[];

    return OrderModel(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name'].toString()
          : json['client_name']?.toString() ??
              json['customer_name']?.toString() ??
              'Unknown',
      reference: json['reference']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      status: json['status']?.toString(),
      eventDate: json['event_date']?.toString(),
      eventTime: json['event_time']?.toString(),
      estimatedPersons: _toInt(json['estimated_persons']) ?? 0,
      perDishAmount: _toDouble(json['per_dish_amount']),
      extraServiceAmount: _toDouble(json['extra_service_amount']),
      waiterServiceAmount: _toDouble(json['waiter_service_amount']),
      advanceAmount: _toDouble(json['advance_amount']),
      eventAddress: json['event_address']?.toString(),
      sessions: sessionList,
      rawData: Map<String, dynamic>.from(json),
    );
  }

  List<OrderSessionModel> get effectiveSessions => sessions.isNotEmpty
      ? sessions
      : [OrderSessionModel.fallbackFromOrder(this)];

  int get totalSessions => effectiveSessions.length;

  int get totalEstimatedPersons => effectiveSessions.fold(
        0,
        (sum, session) => sum + session.estimatedPersons,
      );

  double get totalDishAmount => effectiveSessions.fold(
        0,
        (sum, session) => sum + session.totalDishAmount,
      );

  double get totalExtraAmount => effectiveSessions.fold(
        0,
        (sum, session) =>
            sum + session.extraServiceAmount + session.waiterServiceAmount,
      );

  double get totalAmount => effectiveSessions.fold(
        0,
        (sum, session) => sum + session.totalAmount,
      );

  double get remainingAmount {
    final remaining = totalAmount - advanceAmount;
    return remaining < 0 ? 0 : remaining;
  }

  List<String> get uniqueEventDates {
    final values = <String>{};
    for (final session in effectiveSessions) {
      final value = session.eventDate?.trim();
      if (value != null && value.isNotEmpty) {
        values.add(value);
      }
    }
    return values.toList();
  }

  String get eventDateSummary =>
      uniqueEventDates.isEmpty ? '—' : uniqueEventDates.join(', ');

  String get formattedEventDateSummary => uniqueEventDates.isEmpty
      ? '—'
      : uniqueEventDates.map(_formatDisplayDate).join(', ');

  String get displayInitial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  static String _formatDisplayDate(String value) {
    final input = value.trim();
    if (input.isEmpty) return '—';

    final ddmmyyyy = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$');
    final yyyymmdd = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$');

    final ddmmyyyyMatch = ddmmyyyy.firstMatch(input);
    if (ddmmyyyyMatch != null) {
      final parsed = DateTime(
        int.parse(ddmmyyyyMatch.group(3)!),
        int.parse(ddmmyyyyMatch.group(2)!),
        int.parse(ddmmyyyyMatch.group(1)!),
      );
      return DateFormat('dd MMM yyyy').format(parsed);
    }

    final yyyymmddMatch = yyyymmdd.firstMatch(input);
    if (yyyymmddMatch != null) {
      final parsed = DateTime(
        int.parse(yyyymmddMatch.group(1)!),
        int.parse(yyyymmddMatch.group(2)!),
        int.parse(yyyymmddMatch.group(3)!),
      );
      return DateFormat('dd MMM yyyy').format(parsed);
    }

    final parsed = DateTime.tryParse(input);
    if (parsed == null) return input;

    return DateFormat('dd MMM yyyy').format(parsed);
  }

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
