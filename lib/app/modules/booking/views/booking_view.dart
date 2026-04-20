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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Event Booking",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 24),
              
              // Step Progress
              Obx(() => Row(
                children: [
                  _buildStepIndicator(context, 0, "Client Info", controller.currentStep.value >= 0),
                  _buildLine(controller.currentStep.value >= 1),
                  _buildStepIndicator(context, 1, "Schedule", controller.currentStep.value >= 1),
                  _buildLine(controller.currentStep.value >= 2),
                  _buildStepIndicator(context, 2, "Dishes", controller.currentStep.value >= 2),
                ],
              )),
              
              const SizedBox(height: 32),
              
              // Content Area
              Expanded(
                child: Card(
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
              ),
              
              const SizedBox(height: 24),
              
              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => controller.currentStep.value > 0
                      ? OutlinedButton(
                          onPressed: controller.previousStep,
                          child: const Text("Back"),
                        )
                      : const SizedBox()),
                  Obx(() => ElevatedButton(
                    onPressed: controller.currentStep.value == 2
                        ? controller.submitBooking
                        : controller.nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(controller.currentStep.value == 2 ? "Finish" : "Next"),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (step + 1).toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Client Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildTextField("Client Name", controller.clientName, Icons.person),
        const SizedBox(height: 16),
        _buildTextField("Mobile Number", controller.mobileNo, Icons.phone),
        const SizedBox(height: 16),
        _buildTextField("Reference", controller.reference, Icons.link),
      ],
    );
  }

  Widget _buildScheduleInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Event Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ListTile(
          title: const Text("Event Date"),
          subtitle: Obx(() => Text(controller.eventDate.value.toString().split(' ')[0])),
          trailing: const Icon(Icons.calendar_today),
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
          Text("Dish Selection Logic", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Select items from categories to add to the menu"),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
