import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                _buildStepperHeader(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Obx(() {
                      switch (controller.currentStep.value) {
                        case 0: return _buildClientInfo();
                        case 1: return _buildScheduleInfo(context);
                        case 2: return _buildDishSelection();
                        default: return const SizedBox();
                      }
                    }),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF845CBD), Color(0xFF6A3FAF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepItem(0, "Client & Event", Icons.person_outline),
          _buildConnector(0),
          _buildStepItem(1, "Menu Selection", Icons.grid_view_rounded),
          _buildConnector(1),
          _buildStepItem(2, "Summary & Services", Icons.assignment_outlined),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, IconData icon) {
    return Obx(() {
      bool isActive = controller.currentStep.value == step;
      bool isCompleted = controller.currentStep.value > step;
      
      return Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : (isActive ? Colors.white : Colors.white24),
              shape: BoxShape.circle,
              boxShadow: (isActive || isCompleted) ? [
                BoxShadow(
                  color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              size: 20,
              color: isCompleted ? Colors.white : (isActive ? AppColors.primary : Colors.white60),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isActive ? Colors.white : (isCompleted ? Colors.green[200] : Colors.white54),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildConnector(int step) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
        child: Obx(() {
          bool isCompleted = controller.currentStep.value > step;
          return Container(
            height: 3,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Client Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildTextField("Client Name", controller.clientName, Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField("Mobile Number", controller.mobileNo, Icons.phone_outlined),
        const SizedBox(height: 16),
        _buildTextField("Reference", controller.reference, Icons.link_rounded),
      ],
    );
  }

  Widget _buildScheduleInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Event Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          color: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: const Text("Select Event Date", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Obx(() => Text(controller.eventDate.value.toString().split(' ')[0], style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold))),
            trailing: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.eventDate.value,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) controller.eventDate.value = picked;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDishSelection() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 64, color: AppColors.primary),
          SizedBox(height: 16),
          Text("Dish Selection Logic", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text("Select items from categories to add to the menu", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => controller.currentStep.value > 0
              ? OutlinedButton.icon(
                  onPressed: controller.previousStep,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text("Back"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              : const SizedBox()),
          Obx(() => ElevatedButton(
            onPressed: controller.currentStep.value == 2
                ? controller.submitBooking
                : controller.nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              children: [
                Text(controller.currentStep.value == 2 ? "Confirm Booking" : "Continue"),
                const SizedBox(width: 8),
                Icon(controller.currentStep.value == 2 ? Icons.check_circle_outline : Icons.chevron_right),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
