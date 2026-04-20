import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  // Current step in the wizard
  final currentStep = 0.obs;
  
  // Form Data (simplified from React DishController.jsx)
  final clientName = TextEditingController();
  final mobileNo = TextEditingController();
  final reference = TextEditingController();
  final eventDate = DateTime.now().add(const Duration(days: 1)).obs;
  
  final isLoading = false.obs;

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> submitBooking() async {
    isLoading.value = true;
    try {
      // Logic for submitting to /event-bookings/
      Get.snackbar("Success", "Booking created successfully");
      Get.offNamed('/all-order');
    } catch (e) {
      Get.snackbar("Error", "Failed to create booking");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    clientName.dispose();
    mobileNo.dispose();
    reference.dispose();
    super.onClose();
  }
}
