import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  // Navigation
  final currentStep = 0.obs;

  // Client Info
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final referenceController = TextEditingController();
  final orderDate = DateTime.now().obs;

  // Schedule Data
  final schedule = <EventDay>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add initial day and slot as per React logic
    addSchedule();
  }

  void addSchedule() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    schedule.add(EventDay(
      eventDate: tomorrow,
      timeSlots: [EventSlot()].obs,
    ));
  }

  void removeSchedule(int index) {
    if (schedule.length > 1) {
      schedule.removeAt(index);
    }
  }

  void addTimeSlot(int dayIndex) {
    schedule[dayIndex].timeSlots.add(EventSlot());
  }

  void removeTimeSlot(int dayIndex, int slotIndex) {
    if (schedule[dayIndex].timeSlots.length > 1) {
      schedule[dayIndex].timeSlots.removeAt(slotIndex);
    }
  }

  void updateScheduleDate(int index, DateTime date) {
    schedule[index] = EventDay(
      eventDate: date,
      timeSlots: schedule[index].timeSlots,
    );
  }

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void validateAndContinue() {
    final clientName = nameController.text.trim();
    final mobileNumber =
        mobileController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (clientName.isEmpty) {
      Get.snackbar('Error', 'Client name is required');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(mobileNumber)) {
      Get.snackbar('Error', 'Mobile number must be exactly 10 digits');
      return;
    }

    if (schedule.isEmpty) {
      Get.snackbar('Error', 'Please add at least one event date');
      return;
    }

    for (var dayIndex = 0; dayIndex < schedule.length; dayIndex++) {
      final day = schedule[dayIndex];

      if (day.timeSlots.isEmpty) {
        Get.snackbar(
          'Error',
          'Please add at least one time slot for day ${dayIndex + 1}',
        );
        return;
      }

      for (var slotIndex = 0; slotIndex < day.timeSlots.length; slotIndex++) {
        final slot = day.timeSlots[slotIndex];
        final persons = int.tryParse(slot.estimatedPersons.value.trim());

        if (slot.timeLabel.value.trim().isEmpty) {
          Get.snackbar(
            'Error',
            'Please select timing for day ${dayIndex + 1}, slot ${slotIndex + 1}',
          );
          return;
        }

        if (persons == null || persons <= 0) {
          Get.snackbar(
            'Error',
            'Please enter valid person required for day ${dayIndex + 1}, slot ${slotIndex + 1}',
          );
          return;
        }
      }
    }

    Get.snackbar('Success', 'All required fields are set');
    nextStep();
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> submitBooking() async {
    isLoading.value = true;
    try {
      Get.snackbar("Success", "Booking created successfully");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    referenceController.dispose();
    super.onClose();
  }
}

class EventDay {
  final DateTime eventDate;
  final RxList<EventSlot> timeSlots;

  EventDay({required this.eventDate, required this.timeSlots});
}

class EventSlot {
  final timeLabel = "".obs;
  final estimatedPersons = "".obs;
}
