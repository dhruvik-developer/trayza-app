import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/payment_history_model.dart';
import '../../../data/providers/payment_history_provider.dart';

class PaymentHistoryController extends GetxController {
  final PaymentHistoryProvider _provider = PaymentHistoryProvider();

  final isLoading = true.obs;
  final paymentHistory = Rxn<PaymentHistoryModel>();
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _provider.getPaymentHistory();
      if (response.data['status'] == true && response.data['data'] != null) {
        paymentHistory.value =
            PaymentHistoryModel.fromJson(response.data['data']);
        return;
      }

      paymentHistory.value = null;
      errorMessage.value = response.data['message']?.toString() ??
          'No payment history available.';
    } catch (e) {
      paymentHistory.value = null;
      errorMessage.value = 'Failed to fetch payment history.';
      Get.snackbar(
        'Error',
        'Failed to fetch payment history',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
