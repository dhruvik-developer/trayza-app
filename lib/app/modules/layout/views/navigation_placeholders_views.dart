import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trayza_app/app/modules/create_ingredient/controllers/create_ingredient_controller.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/navigation_placeholders.dart';

class PaymentHistoryView extends GetView<PaymentHistoryController> {
  const PaymentHistoryView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(6, "Payment History", Icons.history_rounded);
}

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(7, "Expense", Icons.payments_outlined);
}

class CreateIngredientView extends GetView<CreateIngredientController> {
  const CreateIngredientView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(8, "Create Ingredient", Icons.note_add_outlined);
}

class EventSummaryView extends GetView<EventSummaryController> {
  const EventSummaryView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(10, "Event Summary", Icons.description_outlined);
}

class GroundChecklistView extends GetView<GroundChecklistController> {
  const GroundChecklistView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(11, "Ground Checklist", Icons.rule_folder_outlined);
}

Widget _buildPlaceholder(int index, String title, IconData icon) {
  return LayoutView(
    activeIndex: index,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
            const Text("Module migration in progress", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
}
