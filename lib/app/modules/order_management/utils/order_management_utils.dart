import 'package:intl/intl.dart';

import '../../../data/models/order_model.dart';

class OrderManagementUtils {
  static DateTime? parseFlexibleDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final input = value.trim();

    final ddmmyyyy = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$');
    final yyyymmdd = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$');

    final ddmmyyyyMatch = ddmmyyyy.firstMatch(input);
    if (ddmmyyyyMatch != null) {
      return DateTime(
        int.parse(ddmmyyyyMatch.group(3)!),
        int.parse(ddmmyyyyMatch.group(2)!),
        int.parse(ddmmyyyyMatch.group(1)!),
      );
    }

    final yyyymmddMatch = yyyymmdd.firstMatch(input);
    if (yyyymmddMatch != null) {
      return DateTime(
        int.parse(yyyymmddMatch.group(1)!),
        int.parse(yyyymmddMatch.group(2)!),
        int.parse(yyyymmddMatch.group(3)!),
      );
    }

    return DateTime.tryParse(input);
  }

  static String formatDisplayDate(String? value) {
    final parsed = parseFlexibleDate(value);
    if (parsed == null) {
      return value?.trim().isNotEmpty == true ? value!.trim() : '—';
    }
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  static String formatDateValue(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('dd MMM yyyy').format(value);
  }

  static String formatApiDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String formatCurrency(num value, {bool withSymbol = true}) {
    final formatted = NumberFormat('#,##,##0.00', 'en_IN').format(value);
    return withSymbol ? '₹ $formatted' : formatted;
  }

  static bool orderMatchesDateRange(
    OrderModel order,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return true;

    final normalizedStart = startDate == null
        ? null
        : DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = endDate == null
        ? null
        : DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    for (final session in order.effectiveSessions) {
      final parsed = parseFlexibleDate(session.eventDate);
      if (parsed == null) continue;

      final current = DateTime(parsed.year, parsed.month, parsed.day);

      if (normalizedStart != null && current.isBefore(normalizedStart)) {
        continue;
      }
      if (normalizedEnd != null && current.isAfter(normalizedEnd)) {
        continue;
      }
      return true;
    }

    return false;
  }

  static List<dynamic> extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) return data;
      final results = responseData['results'];
      if (results is List) return results;
    }
    return const [];
  }

  static Map<String, dynamic> normalizeSelectedItems(dynamic selectedItems) {
    if (selectedItems is! Map) return <String, dynamic>{};

    final transformed = <String, dynamic>{};
    for (final entry in selectedItems.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is! List) continue;

      transformed[key] = value
          .map<Map<String, dynamic>?>((item) {
            if (item is Map) {
              final name = item['name'];
              if (name is Map && name['name'] != null) {
                return {'name': name['name'].toString()};
              }
              if (name != null) {
                return {'name': name.toString()};
              }
            }
            if (item != null) {
              return {'name': item.toString()};
            }
            return null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return transformed;
  }
}
