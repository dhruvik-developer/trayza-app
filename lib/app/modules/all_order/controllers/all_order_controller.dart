import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/services/pdf_service.dart';
import '../../order_management/utils/order_management_utils.dart';

class AllOrderController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  final PdfService _pdfService = PdfService();

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<OrderModel> get filteredOrders {
    final query = searchQuery.value.trim().toLowerCase();

    return orders.where((order) {
      final matchesQuery = query.isEmpty ||
          order.name.toLowerCase().contains(query) ||
          (order.mobileNo?.contains(query) ?? false);
      if (!matchesQuery) {
        return false;
      }

      return OrderManagementUtils.orderMatchesDateRange(
        order,
        startDate.value,
        endDate.value,
      );
    }).toList();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final response = await _orderProvider.getAllOrders();
      final rawList = OrderManagementUtils.extractList(response.data);
      orders.assignAll(
        rawList
            .whereType<Map>()
            .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to fetch orders.');
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void applyQuickFilter(String type) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    switch (type) {
      case 'today':
        startDate.value = normalizedToday;
        endDate.value = normalizedToday;
        break;
      case 'thisWeek':
        final firstDayOfWeek = normalizedToday.subtract(
          Duration(days: normalizedToday.weekday - 1),
        );
        startDate.value = firstDayOfWeek;
        endDate.value = firstDayOfWeek.add(const Duration(days: 6));
        break;
      case 'thisMonth':
        startDate.value = DateTime(today.year, today.month, 1);
        endDate.value = DateTime(today.year, today.month + 1, 0);
        break;
      case 'next7Days':
      case 'upcoming':
        startDate.value = normalizedToday;
        endDate.value = normalizedToday.add(const Duration(days: 6));
        break;
      default:
        startDate.value = null;
        endDate.value = null;
    }
  }

  Future<void> pickDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: startDate.value == null || endDate.value == null
          ? null
          : DateTimeRange(start: startDate.value!, end: endDate.value!),
    );

    if (range == null) return;
    startDate.value = range.start;
    endDate.value = range.end;
  }

  void clearDateRange() {
    startDate.value = null;
    endDate.value = null;
  }

  Future<void> previewOrder(OrderModel order) async {
    final detailedOrder = await _getDetailedOrder(order);
    await _pdfService.generateOrderPdf(
      detailedOrder,
      title: 'Order Summary',
      subtitle: 'Confirmed event order overview',
    );
  }

  Future<void> shareOrder(OrderModel order) async {
    final detailedOrder = await _getDetailedOrder(order);
    await _pdfService.shareOrderPdf(
      detailedOrder,
      title: 'Order Summary',
      subtitle: 'Confirmed event order overview',
    );
  }

  Future<void> showOrderDetails(BuildContext context, OrderModel order) async {
    final detailedOrder = await _getDetailedOrder(order);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(detailedOrder.name),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DetailPill(
                        icon: Icons.phone_outlined,
                        label: detailedOrder.mobileNo?.isNotEmpty == true
                            ? detailedOrder.mobileNo!
                            : 'No mobile number',
                      ),
                      _DetailPill(
                        icon: Icons.calendar_today_outlined,
                        label: detailedOrder.formattedEventDateSummary,
                      ),
                      _DetailPill(
                        icon: Icons.group_outlined,
                        label:
                            '${detailedOrder.totalEstimatedPersons} estimated persons',
                      ),
                    ],
                  ),
                  if ((detailedOrder.eventAddress ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Event Address',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(detailedOrder.eventAddress!),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'Sessions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ...detailedOrder.effectiveSessions.map(
                    (session) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4FB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${OrderManagementUtils.formatDisplayDate(session.eventDate)} • ${session.eventTime ?? '—'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dish rate: ${OrderManagementUtils.formatCurrency(session.perDishAmount)}',
                          ),
                          Text(
                              'Estimated persons: ${session.estimatedPersons}'),
                          if (session.extraServiceAmount > 0)
                            Text(
                              'Extra service: ${OrderManagementUtils.formatCurrency(session.extraServiceAmount)}',
                            ),
                          if (session.waiterServiceAmount > 0)
                            Text(
                              'Waiter service: ${OrderManagementUtils.formatCurrency(session.waiterServiceAmount)}',
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Session total: ${OrderManagementUtils.formatCurrency(session.totalAmount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order total: ${OrderManagementUtils.formatCurrency(detailedOrder.totalAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Received so far: ${OrderManagementUtils.formatCurrency(detailedOrder.advanceAmount)}',
                  ),
                  Text(
                    'Pending: ${OrderManagementUtils.formatCurrency(detailedOrder.remainingAmount)}',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelOrder(OrderModel order) async {
    final shouldCancel = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Cancel order?'),
            content: Text('This will cancel the order for ${order.name}.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Back'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Cancel order'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldCancel) return;

    try {
      await _orderProvider.changeStatus(order.id, 'cancelled');
      Get.snackbar('Success', 'Order cancelled successfully.');
      await fetchOrders();
    } catch (_) {
      Get.snackbar('Error', 'Failed to cancel order.');
    }
  }

  Future<void> completeOrder(BuildContext context, OrderModel order) async {
    try {
      final payloadData = await _getDetailedOrderPayload(order.id);
      final detailedOrder = OrderModel.fromJson(payloadData);
      final editableSessions = detailedOrder.effectiveSessions
          .map((session) => _EditableSession(session))
          .toList();
      final completionController = TextEditingController();
      final noteController = TextEditingController(
        text: 'Order completion payment',
      );
      String paymentMode = 'CASH';
      String? validationMessage;

      double totalDishAmount() => editableSessions.fold(
            0,
            (sum, session) =>
                sum + (session.perDishAmount * session.estimatedPersons),
          );

      int totalDishCount() => editableSessions.fold(
            0,
            (sum, session) => sum + session.estimatedPersons,
          );

      double totalExtraAmount() => detailedOrder.effectiveSessions.fold(
            0,
            (sum, session) =>
                sum + session.extraServiceAmount + session.waiterServiceAmount,
          );

      double totalAmount() => totalDishAmount() + totalExtraAmount();

      double currentPendingAmount() {
        final pending = totalAmount() - detailedOrder.advanceAmount;
        return pending < 0 ? 0 : pending;
      }

      final submitted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              final completionAmount =
                  double.tryParse(completionController.text.trim()) ?? 0;
              final pendingAfterPayment = math.max(
                0,
                currentPendingAmount() - completionAmount,
              );

              return AlertDialog(
                title: Text('Complete Order: ${detailedOrder.name}'),
                content: SizedBox(
                  width: 620,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...editableSessions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final session = entry.value;

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: index == editableSessions.length - 1
                                  ? 16
                                  : 12,
                            ),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4FB),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${OrderManagementUtils.formatDisplayDate(session.source.eventDate)} • ${session.source.eventTime ?? 'Session ${index + 1}'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: session.perDishController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Per dish price',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (_) => setState(() {
                                          validationMessage = null;
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: session.estimatedController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Dish count',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (_) => setState(() {
                                          validationMessage = null;
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Session total: ${OrderManagementUtils.formatCurrency(session.totalAmount)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (session.source.extraServiceAmount > 0)
                                  Text(
                                    'Extra service: ${OrderManagementUtils.formatCurrency(session.source.extraServiceAmount)}',
                                  ),
                                if (session.source.waiterServiceAmount > 0)
                                  Text(
                                    'Waiter service: ${OrderManagementUtils.formatCurrency(session.source.waiterServiceAmount)}',
                                  ),
                              ],
                            ),
                          );
                        }),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SummaryLine(
                                label: 'Total dish count',
                                value: totalDishCount().toString(),
                              ),
                              _SummaryLine(
                                label: 'Total dish amount',
                                value: OrderManagementUtils.formatCurrency(
                                  totalDishAmount(),
                                ),
                              ),
                              _SummaryLine(
                                label: 'Extra charges',
                                value: OrderManagementUtils.formatCurrency(
                                  totalExtraAmount(),
                                ),
                              ),
                              const Divider(height: 22),
                              _SummaryLine(
                                label: 'Total amount',
                                value: OrderManagementUtils.formatCurrency(
                                  totalAmount(),
                                ),
                                emphasize: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Text(
                            'Advance paid at confirmation: ${OrderManagementUtils.formatCurrency(detailedOrder.advanceAmount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: paymentMode,
                          decoration: const InputDecoration(
                            labelText: 'Payment mode',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'CASH', child: Text('Cash')),
                            DropdownMenuItem(
                              value: 'ONLINE',
                              child: Text('Online'),
                            ),
                            DropdownMenuItem(
                              value: 'CHEQUE',
                              child: Text('Cheque'),
                            ),
                            DropdownMenuItem(
                              value: 'BANK_TRANSFER',
                              child: Text('Bank Transfer'),
                            ),
                            DropdownMenuItem(
                                value: 'OTHER', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              paymentMode = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: completionController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount paid at completion',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {
                            validationMessage = null;
                          }),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: noteController,
                          decoration: const InputDecoration(
                            labelText: 'Note / reference',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Remaining after completion: ${OrderManagementUtils.formatCurrency(pendingAfterPayment)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (validationMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            validationMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final completionAmount =
                          double.tryParse(completionController.text.trim()) ??
                              0;
                      if (completionAmount > currentPendingAmount()) {
                        setState(() {
                          validationMessage =
                              'Payment cannot exceed the pending amount.';
                        });
                        return;
                      }
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (submitted != true) {
        completionController.dispose();
        noteController.dispose();
        for (final session in editableSessions) {
          session.dispose();
        }
        return;
      }

      final completionAmount =
          double.tryParse(completionController.text.trim()) ?? 0;
      final updatedAdvanceAmount =
          detailedOrder.advanceAmount + completionAmount;
      final paymentNote = noteController.text.trim().isEmpty
          ? 'Order completion payment'
          : noteController.text.trim();

      completionController.dispose();
      noteController.dispose();

      final sessionPayloads = (payloadData['sessions'] as List?)
              ?.whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          const <Map<String, dynamic>>[];

      final updatePayload = Map<String, dynamic>.from(payloadData)
        ..['advance_amount'] = updatedAdvanceAmount
        ..['status'] = 'done'
        ..['per_dish_amount'] = editableSessions.first.perDishAmount
        ..['estimated_persons'] = editableSessions.first.estimatedPersons
        ..['sessions'] = sessionPayloads.isEmpty
            ? <Map<String, dynamic>>[]
            : List.generate(sessionPayloads.length, (index) {
                final sessionPayload =
                    Map<String, dynamic>.from(sessionPayloads[index]);
                final updatedSession = editableSessions[index];

                return {
                  ...sessionPayload,
                  'per_dish_amount': updatedSession.perDishAmount,
                  'estimated_persons': updatedSession.estimatedPersons,
                  'selected_items': OrderManagementUtils.normalizeSelectedItems(
                    sessionPayload['selected_items'],
                  ),
                };
              });

      await _orderProvider.updateOrder(order.id, updatePayload);
      await _orderProvider.addPayment({
        'booking': order.id,
        'total_amount': editableSessions.fold<double>(
          0,
          (sum, session) => sum + session.totalAmount,
        ),
        'pending_amount': math.max(
          0,
          editableSessions.fold<double>(
                0,
                (sum, session) => sum + session.totalAmount,
              ) -
              updatedAdvanceAmount,
        ),
        'advance_amount': updatedAdvanceAmount,
        'payment_date': OrderManagementUtils.formatApiDate(DateTime.now()),
        'transaction_amount': completionAmount,
        'settlement_amount': 0,
        'payment_mode': paymentMode,
        'note': paymentNote,
        'total_extra_amount': detailedOrder.totalExtraAmount,
      });

      for (final session in editableSessions) {
        session.dispose();
      }

      Get.snackbar('Success', 'Order completed successfully.');
      await fetchOrders();
    } catch (_) {
      Get.snackbar('Error', 'Failed to complete order.');
    }
  }

  Future<OrderModel> _getDetailedOrder(OrderModel fallback) async {
    try {
      final payload = await _getDetailedOrderPayload(fallback.id);
      return OrderModel.fromJson(payload);
    } catch (_) {
      return fallback;
    }
  }

  Future<Map<String, dynamic>> _getDetailedOrderPayload(int id) async {
    final response = await _orderProvider.getOrderDetails(id);
    return Map<String, dynamic>.from(
      response.data['data'] as Map? ?? const {},
    );
  }
}

class _EditableSession {
  _EditableSession(this.source)
      : perDishController = TextEditingController(
          text: source.perDishAmount.toStringAsFixed(
            source.perDishAmount % 1 == 0 ? 0 : 2,
          ),
        ),
        estimatedController = TextEditingController(
          text: source.estimatedPersons.toString(),
        );

  final OrderSessionModel source;
  final TextEditingController perDishController;
  final TextEditingController estimatedController;

  double get perDishAmount =>
      double.tryParse(perDishController.text.trim()) ?? 0;

  int get estimatedPersons =>
      int.tryParse(estimatedController.text.trim()) ?? 0;

  double get totalAmount =>
      (perDishAmount * estimatedPersons) +
      source.extraServiceAmount +
      source.waiterServiceAmount;

  void dispose() {
    perDishController.dispose();
    estimatedController.dispose();
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
      fontSize: emphasize ? 16 : 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: textStyle),
          ),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}
