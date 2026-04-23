import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/invoice_model.dart';
import '../../../data/providers/invoice_provider.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/services/pdf_service.dart';
import '../../order_management/utils/order_management_utils.dart';

class InvoiceController extends GetxController {
  final InvoiceProvider _invoiceProvider = InvoiceProvider();
  final OrderProvider _orderProvider = OrderProvider();
  final PdfService _pdfService = PdfService();

  final invoices = <InvoiceModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<String> get filterOptions => const ['All', 'Paid', 'Unpaid'];

  List<InvoiceModel> get filteredInvoices {
    final query = searchQuery.value.trim().toLowerCase();

    return invoices.where((invoice) {
      final matchesFilter = switch (selectedFilter.value) {
        'Paid' => invoice.isPaid,
        'Unpaid' => !invoice.isPaid,
        _ => true,
      };
      if (!matchesFilter) return false;

      final matchesQuery = query.isEmpty ||
          invoice.booking.name.toLowerCase().contains(query) ||
          (invoice.booking.mobileNo?.contains(query) ?? false);
      if (!matchesQuery) return false;

      return _invoiceMatchesDateRange(invoice);
    }).toList();
  }

  Future<void> fetchInvoices() async {
    isLoading.value = true;
    try {
      final response = await _invoiceProvider.getInvoices();
      final rawList = OrderManagementUtils.extractList(response.data);
      invoices.assignAll(
        rawList
            .whereType<Map>()
            .map((item) => InvoiceModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to fetch invoices.');
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

  void updateFilter(String? value) {
    if (value == null || value == selectedFilter.value) return;
    selectedFilter.value = value;
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
      default:
        startDate.value = null;
        endDate.value = null;
    }
  }

  Future<void> pickDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  Future<void> previewOrderCopy(InvoiceModel invoice) async {
    final detailedInvoice = await _getDetailedInvoice(invoice);
    await _pdfService.generateInvoicePdf(
      detailedInvoice,
      title: 'Invoice Order Copy',
      subtitle: 'Detailed order copy for billing reference',
    );
  }

  Future<void> shareBill(InvoiceModel invoice) async {
    final detailedInvoice = await _getDetailedInvoice(invoice);
    await _pdfService.shareBillPdf(
      detailedInvoice,
      title: 'Customer Bill',
      subtitle: 'Billing copy ready to share with the client',
    );
  }

  Future<void> completePayment(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    final currentPending = invoice.displayPendingAmount;
    if (currentPending <= 0) {
      Get.snackbar('Done', 'This invoice is already fully paid.');
      return;
    }

    final transactionController = TextEditingController();
    final settlementController = TextEditingController();
    final noteController = TextEditingController(text: 'Invoice settlement');
    String paymentMode =
        invoice.paymentMode.isNotEmpty ? invoice.paymentMode : 'CASH';
    String? validationMessage;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final transactionAmount =
                double.tryParse(transactionController.text.trim()) ?? 0;
            final settlementAmount =
                double.tryParse(settlementController.text.trim()) ?? 0;
            final totalPaidNow = transactionAmount + settlementAmount;
            final pendingAfter = math.max(0, currentPending - totalPaidNow);

            return AlertDialog(
              title: Text('Complete Payment: ${invoice.booking.name}'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pending Amount',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              OrderManagementUtils.formatCurrency(currentPending),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
                        controller: transactionController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Transaction Amount',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {
                          validationMessage = null;
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: settlementController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Settlement Amount',
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
                          labelText: 'Note / Reference',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Remaining after payment: ${OrderManagementUtils.formatCurrency(pendingAfter)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final transactionAmount =
                        double.tryParse(transactionController.text.trim()) ?? 0;
                    final settlementAmount =
                        double.tryParse(settlementController.text.trim()) ?? 0;
                    final totalPaidNow = transactionAmount + settlementAmount;

                    if (totalPaidNow <= 0) {
                      setState(() {
                        validationMessage =
                            'Enter a transaction or settlement amount.';
                      });
                      return;
                    }

                    if (totalPaidNow > currentPending) {
                      setState(() {
                        validationMessage =
                            'Payment cannot exceed the pending amount.';
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true) {
      transactionController.dispose();
      settlementController.dispose();
      noteController.dispose();
      return;
    }

    final transactionAmount =
        double.tryParse(transactionController.text.trim()) ?? 0;
    final settlementAmount =
        double.tryParse(settlementController.text.trim()) ?? 0;
    final totalPaidNow = transactionAmount + settlementAmount;
    final pendingAfter = math.max(0, currentPending - totalPaidNow);
    final note = noteController.text.trim();

    transactionController.dispose();
    settlementController.dispose();
    noteController.dispose();

    if (invoice.billNo.isEmpty) {
      Get.snackbar('Error', 'Invoice identifier is missing.');
      return;
    }

    final payload = <String, dynamic>{
      'booking': invoice.booking.id,
      'total_amount': invoice.totalAmount,
      'advance_amount': invoice.advanceAmount,
      'pending_amount': pendingAfter,
      'payment_date': OrderManagementUtils.formatApiDate(DateTime.now()),
      'transaction_amount': transactionAmount,
      'settlement_amount': settlementAmount,
      'payment_mode': paymentMode,
      'payment_status': pendingAfter <= 0 ? 'PAID' : 'PARTIAL',
      'total_extra_amount': invoice.totalExtraAmount,
    };

    if (note.isNotEmpty) {
      payload['note'] = note;
    }

    try {
      await _invoiceProvider.updatePayment(invoice.billNo, payload);
      Get.snackbar('Success', 'Invoice payment updated successfully.');
      await fetchInvoices();
    } catch (_) {
      Get.snackbar('Error', 'Failed to update invoice payment.');
    }
  }

  bool _invoiceMatchesDateRange(InvoiceModel invoice) {
    if (startDate.value == null && endDate.value == null) return true;

    final normalizedStart = startDate.value == null
        ? null
        : DateTime(
            startDate.value!.year,
            startDate.value!.month,
            startDate.value!.day,
          );
    final normalizedEnd = endDate.value == null
        ? null
        : DateTime(
            endDate.value!.year,
            endDate.value!.month,
            endDate.value!.day,
            23,
            59,
            59,
            999,
          );

    final candidates = <String>[
      ...invoice.booking.effectiveSessions
          .map((session) => session.eventDate ?? '')
          .where((value) => value.trim().isNotEmpty),
      if ((invoice.formattedEventDate ?? '').trim().isNotEmpty)
        invoice.formattedEventDate!,
    ];

    for (final value in candidates) {
      final parsed = OrderManagementUtils.parseFlexibleDate(value);
      if (parsed == null) continue;

      final normalizedDate = DateTime(parsed.year, parsed.month, parsed.day);
      if (normalizedStart != null &&
          normalizedDate.isBefore(normalizedStart)) {
        continue;
      }
      if (normalizedEnd != null && normalizedDate.isAfter(normalizedEnd)) {
        continue;
      }
      return true;
    }

    return false;
  }

  Future<InvoiceModel> _getDetailedInvoice(InvoiceModel fallback) async {
    if (fallback.booking.id == 0) return fallback;

    try {
      final response = await _orderProvider.getOrderDetails(fallback.booking.id);
      final detailedOrder =
          Map<String, dynamic>.from(response.data['data'] as Map? ?? const {});

      return InvoiceModel.fromJson(
        <String, dynamic>{
          ...fallback.rawData,
          'booking': <String, dynamic>{
            ...fallback.booking.rawData,
            ...detailedOrder,
          },
        },
      );
    } catch (_) {
      return fallback;
    }
  }
}

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceController>(() => InvoiceController());
  }
}
