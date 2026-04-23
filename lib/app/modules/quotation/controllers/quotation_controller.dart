import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/services/pdf_service.dart';
import '../../order_management/utils/order_management_utils.dart';

class QuotationController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  final PdfService _pdfService = PdfService();

  final quotations = <OrderModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchQuotations();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<OrderModel> get filteredQuotations {
    final query = searchQuery.value.trim().toLowerCase();

    return quotations.where((quotation) {
      final matchesQuery = query.isEmpty ||
          quotation.name.toLowerCase().contains(query) ||
          (quotation.mobileNo?.contains(query) ?? false);
      if (!matchesQuery) return false;

      return OrderManagementUtils.orderMatchesDateRange(
        quotation,
        startDate.value,
        endDate.value,
      );
    }).toList();
  }

  Future<void> fetchQuotations() async {
    isLoading.value = true;
    try {
      final response = await _orderProvider.getPendingQuotations();
      final rawList = OrderManagementUtils.extractList(response.data);
      quotations.assignAll(
        rawList
            .whereType<Map>()
            .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to fetch quotations.');
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
      case 'next7Days':
        startDate.value = normalizedToday;
        endDate.value = normalizedToday.add(const Duration(days: 6));
        break;
      case 'next30Days':
        startDate.value = normalizedToday;
        endDate.value = normalizedToday.add(const Duration(days: 29));
        break;
      default:
        startDate.value = null;
        endDate.value = null;
    }
  }

  Future<void> pickDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: startDate.value == null || endDate.value == null
          ? null
          : DateTimeRange(start: startDate.value!, end: endDate.value!),
    );

    if (range == null) return;
    startDate.value = range.start;
    endDate.value = range.end;
  }

  Future<void> clearDateRange() async {
    startDate.value = null;
    endDate.value = null;
  }

  Future<void> previewQuotation(OrderModel quotation) async {
    await _pdfService.generateBookingPdf(
      {
        ...quotation.rawData,
        'name': quotation.name,
        'mobile_no': quotation.mobileNo,
        'date': quotation.eventDateSummary,
        'grandTotalAmount': quotation.totalAmount.toStringAsFixed(2),
      },
    );
  }

  Future<void> cancelQuotation(OrderModel quotation) async {
    final shouldCancel = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Cancel quotation?'),
            content: Text('This will cancel the quotation for ${quotation.name}.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Back'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Cancel quotation'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldCancel) return;

    try {
      await _orderProvider.changeStatus(quotation.id, 'cancelled');
      Get.snackbar('Success', 'Quotation cancelled successfully.');
      await fetchQuotations();
    } catch (_) {
      Get.snackbar('Error', 'Failed to cancel quotation.');
    }
  }

  Future<void> confirmQuotation(
    BuildContext context,
    OrderModel quotation,
  ) async {
    try {
      final response = await _orderProvider.getOrderDetails(quotation.id);
      final payloadData =
          Map<String, dynamic>.from(response.data['data'] as Map? ?? const {});
      final detailedQuotation = OrderModel.fromJson(payloadData);

      final advanceController = TextEditingController(
        text: detailedQuotation.advanceAmount == 0
            ? ''
            : detailedQuotation.advanceAmount.toStringAsFixed(0),
      );
      String paymentMode = 'CASH';
      String? validationMessage;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final advanceAmount =
                  double.tryParse(advanceController.text.trim()) ?? 0;
              final totalAmount = detailedQuotation.totalAmount;
              final pendingAmount = math.max(0, totalAmount - advanceAmount);

              return AlertDialog(
                title: Text('Confirm Order For ${detailedQuotation.name}'),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.amber.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Order Amount',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                OrderManagementUtils.formatCurrency(totalAmount),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          value: paymentMode,
                          decoration: const InputDecoration(
                            labelText: 'Payment Mode',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                            DropdownMenuItem(
                              value: 'CHEQUE',
                              child: Text('Cheque'),
                            ),
                            DropdownMenuItem(
                              value: 'BANK_TRANSFER',
                              child: Text('Bank Transfer'),
                            ),
                            DropdownMenuItem(
                              value: 'ONLINE',
                              child: Text('Online'),
                            ),
                            DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => paymentMode = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: advanceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Advance Amount',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {
                            validationMessage = null;
                          }),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Remaining after confirmation: ${OrderManagementUtils.formatCurrency(pendingAmount)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (validationMessage != null) ...[
                          const SizedBox(height: 10),
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
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final advanceAmount =
                          double.tryParse(advanceController.text.trim()) ?? 0;
                      if (advanceAmount > detailedQuotation.totalAmount) {
                        setState(() {
                          validationMessage =
                              'Advance amount cannot exceed total order amount.';
                        });
                        return;
                      }
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (confirmed != true) {
        advanceController.dispose();
        return;
      }

      final advanceAmount = double.tryParse(advanceController.text.trim()) ?? 0;
      advanceController.dispose();

      final sessions = (payloadData['sessions'] as List?)
              ?.whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          const <Map<String, dynamic>>[];

      final updatePayload = Map<String, dynamic>.from(payloadData)
        ..['advance_payment_mode'] = paymentMode
        ..['advance_amount'] = advanceAmount
        ..['status'] = 'confirm'
        ..['sessions'] = sessions
            .map((session) => {
                  ...session,
                  'selected_items': OrderManagementUtils.normalizeSelectedItems(
                    session['selected_items'],
                  ),
                })
            .toList();

      await _orderProvider.updateOrder(quotation.id, updatePayload);
      await _orderProvider.addPayment({
        'booking': quotation.id,
        'total_amount': detailedQuotation.totalAmount,
        'pending_amount': math.max(0, detailedQuotation.totalAmount - advanceAmount),
        'advance_amount': advanceAmount,
        'payment_date': OrderManagementUtils.formatApiDate(DateTime.now()),
        'transaction_amount': advanceAmount,
        'settlement_amount': 0,
        'payment_mode': paymentMode,
        'note': 'Quotation confirmation payment',
        'total_extra_amount': detailedQuotation.totalExtraAmount,
      });

      Get.snackbar('Success', 'Quotation confirmed successfully.');
      await fetchQuotations();
    } catch (_) {
      Get.snackbar('Error', 'Failed to confirm quotation.');
    }
  }
}

class QuotationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuotationController>(() => QuotationController());
  }
}
