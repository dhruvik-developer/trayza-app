import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/booking_controller.dart';

class BookingView extends GetView<BookingController> {
  const BookingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutView(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Pixel-Perfect Stepper Header
              _buildStepperHeader(context),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Obx(() {
                    switch (controller.currentStep.value) {
                      case 0:
                        return _buildStep1(context);
                      case 1:
                        return _buildStep2();
                      case 2:
                        return _buildStep3();
                      default:
                        return const SizedBox();
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIcon(0, Icons.person_outline, "Client & Event"),
          _buildStepConnector(0),
          _buildStepIcon(1, Icons.grid_view_rounded, "Menu Selection"),
          _buildStepConnector(1),
          _buildStepIcon(2, Icons.assignment_outlined, "Summary & Services"),
        ],
      ),
    );
  }

  Widget _buildStepIcon(int step, IconData icon, String label) {
    return Obx(() {
      bool isActive = controller.currentStep.value == step;
      bool isCompleted = controller.currentStep.value > step;

      return Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : (isActive ? Colors.white : Colors.white24),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              size: 20,
              color: isActive
                  ? AppColors.primary
                  : (isCompleted ? Colors.white : Colors.white60),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.white54,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStepConnector(int step) {
    return Obx(() {
      bool isCompleted = controller.currentStep.value > step;
      return Container(
        width: 80,
        height: 2,
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
        color: isCompleted ? Colors.green : Colors.white24,
      );
    });
  }

  // --- STEP 1: CLIENT & EVENT ---
  Widget _buildStep1(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Client Info
          _buildSectionHeader(Icons.person_rounded, "Client Information",
              "Enter basic details of the client"),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _buildInputField("Client Name *",
                      controller.nameController, "Enter client name")),
              const SizedBox(width: 24),
              Expanded(
                  child: _buildInputField("Mobile Number *",
                      controller.mobileController, "Mobile Number")),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  "Order Date",
                  TextEditingController(
                      text: DateFormat('dd/MM/yyyy')
                          .format(controller.orderDate.value)),
                  "",
                  enabled: false,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                  child: _buildInputField("Reference Name (Optional)",
                      controller.referenceController, "Reference Name")),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Divider(color: AppColors.border),
          ),

          // Section: Event Schedule
          _buildSectionHeader(Icons.calendar_month_rounded, "Event Schedule",
              "Add event dates and time slots for each day"),
          const SizedBox(height: 24),

          Obx(() => Column(
                children: List.generate(controller.schedule.length,
                    (index) => _buildDayCard(context, index)),
              )),

          const SizedBox(height: 32),

          // Footer Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAddDateButton(),
              _buildContinueButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String hint,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, int dayIndex) {
    final day = controller.schedule[dayIndex];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3E8FF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                    child: Text("${dayIndex + 1}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 12),
              const Text("Event Date:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: day.eventDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null)
                    controller.updateScheduleDate(dayIndex, picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(day.eventDate),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              if (controller.schedule.length > 1)
                IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => controller.removeSchedule(dayIndex)),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => Column(
                children: List.generate(day.timeSlots.length,
                    (slotIndex) => _buildSlotCard(dayIndex, slotIndex)),
              )),
          const SizedBox(height: 12),
          _buildAddSlotButton(dayIndex),
        ],
      ),
    );
  }

  Widget _buildSlotCard(int dayIndex, int slotIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Stack(
        children: [
          // Left Accent Bar
          Container(
            width: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6A3FAF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text("SLOT ${slotIndex + 1}",
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child:
                      _buildMiniLabelInput("EVENT TIMING", "Select Timing..."),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildMiniLabelInput("NUMBER OF PERSONS", "e.g. 250"),
                ),
                if (controller.schedule[dayIndex].timeSlots.length > 1)
                  IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () =>
                          controller.removeTimeSlot(dayIndex, slotIndex)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLabelInput(String label, String hint) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hint,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const Icon(Icons.keyboard_arrow_down,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddSlotButton(int dayIndex) {
    return InkWell(
      onTap: () => controller.addTimeSlot(dayIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              style: BorderStyle.none), // Custom dash border logic can be added
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text("Add Time Slot",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDateButton() {
    return ElevatedButton.icon(
      onPressed: controller.addSchedule,
      icon: const Icon(Icons.add, size: 16),
      label: const Text("Add Event Date"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF5F3FF),
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE9D5FF))),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: controller.nextStep,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
        shadowColor: AppColors.primary.withOpacity(0.3),
      ),
      child: const Row(
        children: [
          Text("Continue to Menu Selection",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 12),
          Icon(Icons.arrow_forward_rounded, size: 18),
        ],
      ),
    );
  }

  // --- STEP 2 Placeholder ---
  Widget _buildStep2() => const Center(child: Text("Menu Selection"));
  // --- STEP 3 Placeholder ---
  Widget _buildStep3() => const Center(child: Text("Summary & Services"));
}
