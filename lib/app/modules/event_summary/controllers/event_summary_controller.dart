import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/event_summary_model.dart';
import '../../../data/providers/event_summary_provider.dart';
import '../../../modules/order_management/utils/order_management_utils.dart';

class EventSummaryController extends GetxController {
  EventSummaryController();

  final EventSummaryProvider _provider = EventSummaryProvider();

  final summaries = <EventSummaryModel>[].obs;
  final isLoading = false.obs;
  final selectedStaffType = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  List<String> get staffTypeOptions => const [
        'All',
        'Fixed',
        'Agency',
        'Contract',
      ];

  Future<void> fetchSummary() async {
    isLoading.value = true;
    try {
      final params = <String, dynamic>{};
      if (selectedStaffType.value != 'All') {
        params['staff_type'] = selectedStaffType.value;
      }

      final response = await _provider.getAssignments(params: params);
      final rawList = OrderManagementUtils.extractList(response.data);
      final assignments = rawList
          .whereType<Map>()
          .map((item) => EventAssignmentModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();

      final grouped = <int?, EventSummaryModel>{};
      for (final assignment in assignments) {
        final current = grouped[assignment.staffId];
        if (current == null) {
          grouped[assignment.staffId] = EventSummaryModel(
            staffId: assignment.staffId,
            staffName: assignment.staffName,
            staffType: assignment.staffType,
            totalAmount: assignment.totalAmount,
            totalPaid: assignment.paidAmount,
            totalPending: assignment.remainingAmount,
            events: [assignment],
          );
          continue;
        }

        grouped[assignment.staffId] = EventSummaryModel(
          staffId: current.staffId,
          staffName: current.staffName,
          staffType: current.staffType,
          totalAmount: current.totalAmount + assignment.totalAmount,
          totalPaid: current.totalPaid + assignment.paidAmount,
          totalPending: current.totalPending + assignment.remainingAmount,
          events: [...current.events, assignment],
        );
      }

      summaries.assignAll(grouped.values);
    } catch (_) {
      Get.snackbar('Error', 'Failed to fetch event summary.');
    } finally {
      isLoading.value = false;
    }
  }

  void updateStaffType(String? value) {
    if (value == null || value == selectedStaffType.value) return;
    selectedStaffType.value = value;
    fetchSummary();
  }

  Future<void> promptPayment(
    BuildContext context, {
    required EventAssignmentModel assignment,
  }) async {
    if (!assignment.canAcceptPayment || assignment.remainingAmount <= 0) {
      Get.snackbar('Info', 'No pending payment left for this assignment.');
      return;
    }

    final paymentController = TextEditingController(
      text: assignment.remainingAmount.toStringAsFixed(2),
    );
    String? validationMessage;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pay ${assignment.staffName}'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.sessionName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(assignment.sessionDate),
                    const SizedBox(height: 16),
                    Text(
                      'Pending: ${OrderManagementUtils.formatCurrency(assignment.remainingAmount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: paymentController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {
                        validationMessage = null;
                      }),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(paymentController.text.trim()) ?? 0;
                    if (amount <= 0) {
                      setState(() {
                        validationMessage =
                            'Payment amount should be greater than zero.';
                      });
                      return;
                    }
                    if (amount > assignment.remainingAmount) {
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
      paymentController.dispose();
      return;
    }

    final amount = double.tryParse(paymentController.text.trim()) ?? 0;
    paymentController.dispose();

    await recordPayment(
      assignment: assignment,
      amount: amount,
    );
  }

  Future<bool> recordPayment({
    required EventAssignmentModel assignment,
    required double amount,
  }) async {
    final newPaidAmount = assignment.paidAmount + amount;
    final newRemainingAmount = assignment.totalAmount - newPaidAmount;

    final payload = Map<String, dynamic>.from(assignment.rawData)
      ..['paid_amount'] = newPaidAmount
      ..['remaining_amount'] = newRemainingAmount
      ..['payment_status'] = newRemainingAmount <= 0 ? 'Paid' : 'Pending'
      ..remove('staff_name')
      ..remove('session_name');

    try {
      await _provider.updateAssignment(assignment.id, payload);
      await fetchSummary();
      Get.snackbar(
        'Success',
        'Payment of ${OrderManagementUtils.formatCurrency(amount)} recorded.',
      );
      return true;
    } catch (_) {
      Get.snackbar('Error', 'Failed to record payment.');
      return false;
    }
  }
}
