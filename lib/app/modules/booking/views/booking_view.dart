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
      activeIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(context.width > 600 ? 24.0 : 12.0),
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
    bool isMobile = context.width < 600;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding:
          EdgeInsets.symmetric(vertical: isMobile ? 12 : 20, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIcon(
              0, Icons.person_outline, isMobile ? "Client" : "Client & Event"),
          _buildStepConnector(0, isMobile),
          _buildStepIcon(
              1, Icons.grid_view_rounded, isMobile ? "Menu" : "Menu Selection"),
          _buildStepConnector(1, isMobile),
          _buildStepIcon(2, Icons.assignment_outlined,
              isMobile ? "Summary" : "Summary & Services"),
        ],
      ),
    );
  }

  Widget _buildStepIcon(int step, IconData icon, String label) {
    return Obx(() {
      bool isActive = controller.currentStep.value == step;
      bool isCompleted = controller.currentStep.value > step;
      bool isMobile = Get.width < 600;

      return Column(
        children: [
          Container(
            width: isMobile ? 36 : 44,
            height: isMobile ? 36 : 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : (isActive ? Colors.white : Colors.white24),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              size: isMobile ? 16 : 20,
              color: isActive
                  ? AppColors.primary
                  : (isCompleted ? Colors.white : Colors.white60),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 8 : 10,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.white54,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStepConnector(int step, bool isMobile) {
    return Obx(() {
      bool isCompleted = controller.currentStep.value > step;
      return Container(
        width: isMobile ? 30 : 80,
        height: 2,
        margin: EdgeInsets.only(left: 4, right: 4, bottom: isMobile ? 16 : 20),
        color: isCompleted ? Colors.green : Colors.white24,
      );
    });
  }

  // --- STEP 1: CLIENT & EVENT ---
  Widget _buildStep1(BuildContext context) {
    bool isMobile = context.width < 600;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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

          // Responsive Rows
          if (isMobile) ...[
            _buildInputField("Client Name *", controller.nameController,
                "Enter client name"),
            const SizedBox(height: 20),
            _buildInputField("Mobile Number *", controller.mobileController,
                "Mobile Number"),
            const SizedBox(height: 20),
            _buildInputField(
                "Order Date",
                TextEditingController(
                    text: DateFormat('dd/MM/yyyy')
                        .format(controller.orderDate.value)),
                "",
                enabled: false),
            const SizedBox(height: 20),
            _buildInputField("Reference Name (Optional)",
                controller.referenceController, "Reference Name"),
          ] else ...[
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
                        enabled: false)),
                const SizedBox(width: 24),
                Expanded(
                    child: _buildInputField("Reference Name (Optional)",
                        controller.referenceController, "Reference Name")),
              ],
            ),
          ],

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
    bool isMobile = Get.width < 600;
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
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
    bool isMobile = context.width < 600;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isMobile ? 12 : 20),
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
                width: 36,
                height: 36,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Event Date:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: Text(
                          DateFormat('dd/MM/yyyy').format(day.eventDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (controller.schedule.length > 1)
                IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
          Container(
            width: 6,
            height: 60, // Fixed height for accent bar
            decoration: BoxDecoration(
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
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text("SLOT ${slotIndex + 1}",
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimingDropdown(dayIndex, slotIndex),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPersonsInput(dayIndex, slotIndex),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  Widget _buildTimingDropdown(int dayIndex, int slotIndex) {
    final slot = controller.schedule[dayIndex].timeSlots[slotIndex];
    final options = [
      {"value": "Breakfast", "label": "Breakfast"},
      {"value": "Lunch", "label": "Lunch"},
      {"value": "Dinner", "label": "Dinner"},
      {"value": "High Tea", "label": "High Tea"},
      {"value": "Late Night Nasto", "label": "Late Night Snack"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TIMING",
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: slot.timeLabel.value.isEmpty
                      ? null
                      : slot.timeLabel.value,
                  hint: const Text("Select...",
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      size: 12, color: Colors.grey),
                  items: options.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt["value"],
                      child: Text(opt["label"]!,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) slot.timeLabel.value = val;
                  },
                ),
              )),
        ),
      ],
    );
  }

  Widget _buildPersonsInput(int dayIndex, int slotIndex) {
    final slot = controller.schedule[dayIndex].timeSlots[slotIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PERSONS",
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: TextField(
            onChanged: (val) => slot.estimatedPersons.value = val,
            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "e.g. 250",
              hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniLabelInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(hint,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      overflow: TextOverflow.ellipsis)),
              const Icon(Icons.keyboard_arrow_down,
                  size: 12, color: Colors.grey),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 14, color: Colors.grey),
            SizedBox(width: 6),
            Text("Add Time Slot",
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDateButton() {
    bool isMobile = Get.width < 600;
    return ElevatedButton.icon(
      onPressed: controller.addSchedule,
      icon: const Icon(Icons.add, size: 14),
      label: Text(isMobile ? "Add Date" : "Add Event Date",
          style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF5F3FF),
        foregroundColor: AppColors.primary,
        padding:
            EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFE9D5FF))),
      ),
    );
  }

  Widget _buildContinueButton() {
    bool isMobile = Get.width < 600;
    return ElevatedButton(
      onPressed: controller.nextStep,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding:
            EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        shadowColor: AppColors.primary.withOpacity(0.2),
      ),
      child: Row(
        children: [
          Text(isMobile ? "Continue" : "Continue to Menu",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }

  // Placeholder steps
  Widget _buildStep2() => const Center(child: Text("Menu Selection"));
  Widget _buildStep3() => const Center(child: Text("Summary & Services"));
}
