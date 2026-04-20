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
