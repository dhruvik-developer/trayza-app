import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/navigation_placeholders.dart';

class GstBillingView extends GetView<GstBillingController> {
  const GstBillingView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(5, "GST Billing", Icons.receipt_long_outlined);
}

class PaymentHistoryView extends GetView<PaymentHistoryController> {
  const PaymentHistoryView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(7, "Payment History", Icons.history_rounded);
}

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(8, "Expense", Icons.payments_outlined);
}

class CreateIngredientView extends GetView<CreateIngredientController> {
  const CreateIngredientView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(9, "Create Ingredient", Icons.note_add_outlined);
}

class EventSummaryView extends GetView<EventSummaryController> {
  const EventSummaryView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(11, "Event Summary", Icons.description_outlined);
}

class GroundChecklistView extends GetView<GroundChecklistController> {
  const GroundChecklistView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _buildPlaceholder(12, "Ground Checklist", Icons.rule_folder_outlined);
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
