import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trayza_app/app/modules/expense/bindings/expense_binding.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/layout_controller.dart';

// Import all views and bindings for direct navigation
import '../../booking/views/booking_view.dart';
import '../../booking/bindings/booking_binding.dart';
import '../../all_order/views/all_order_view.dart';
import '../../all_order/bindings/all_order_binding.dart';
import '../../stock/views/stock_view.dart';
import '../../stock/bindings/stock_binding.dart';
import '../../category/views/category_view.dart';
import '../../category/bindings/category_binding.dart';
import '../../people/views/people_view.dart';
import '../../people/bindings/people_binding.dart';
import '../../quotation/views/quotation_view.dart';
import '../../quotation/controllers/quotation_controller.dart';
import '../../invoice/views/invoice_view.dart';
import '../../invoice/controllers/invoice_controller.dart';
import '../../expense/views/expense_view.dart';
import '../../payment_history/views/payment_history_view.dart';
import '../../create_ingredient/views/create_ingredient_view.dart';
import '../../create_ingredient/controllers/create_ingredient_controller.dart';
import '../../event_summary/views/event_summary_view.dart';
import '../../ground_checklist/views/ground_checklist_view.dart';
import '../controllers/navigation_placeholders.dart';

class LayoutView extends GetView<LayoutController> {
  final Widget child;
  final int activeIndex; // To highlight the active menu item

  const LayoutView({
    Key? key,
    required this.child,
    this.activeIndex = -1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = context.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildMobileHeader(context),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop ? Drawer(child: _buildSidebar(context)) : null,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Logo Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Image.asset('assets/images/logo.png',
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const FlutterLogo(size: 60)),
            ),

            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildSidebarItem(
                      0,
                      'Create Dish',
                      Icons.room_service_outlined,
                      () => Get.offAll(() => const BookingView(),
                          binding: BookingBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      1,
                      'Category',
                      Icons.category_outlined,
                      () => Get.offAll(() => const CategoryView(),
                          binding: CategoryBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      2,
                      'Quotation',
                      Icons.edit_note_rounded,
                      () => Get.offAll(() => const QuotationView(),
                          binding: QuotationBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      3,
                      'All Order',
                      Icons.checklist_rtl_rounded,
                      () => Get.offAll(() => const AllOrderView(),
                          binding: AllOrderBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      4,
                      'Invoice',
                      Icons.receipt_outlined,
                      () => Get.offAll(() => const InvoiceView(),
                          binding: InvoiceBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      5,
                      'Stock',
                      Icons.shopping_bag_outlined,
                      () => Get.offAll(() => const StockView(),
                          binding: StockBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      6,
                      'Payment History',
                      Icons.history_rounded,
                      () => Get.offAll(() => const PaymentHistoryView(),
                          binding: PaymentHistoryBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      7,
                      'Expense',
                      Icons.payments_outlined,
                      () => Get.offAll(() => const ExpenseView(),
                          binding: ExpenseBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      8,
                      'Create Ingredient',
                      Icons.note_add_outlined,
                      () => Get.offAll(() => const CreateIngredientView(),
                          binding: CreateIngredientBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      9,
                      'People',
                      Icons.people_outline_rounded,
                      () => Get.offAll(() => const PeopleView(),
                          binding: PeopleBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      10,
                      'Event Summary',
                      Icons.description_outlined,
                      () => Get.offAll(() => const EventSummaryView(),
                          binding: EventSummaryBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      11,
                      'Ground Checklist',
                      Icons.rule_folder_outlined,
                      () => Get.offAll(() => const GroundChecklistView(),
                          binding: GroundChecklistBinding())),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
      int index, String title, IconData icon, VoidCallback onTap) {
    bool isActive = activeIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isActive ? AppColors.primary : Colors.transparent,
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8))
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive
                      ? null
                      : [
                          const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              // Menu button
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.primary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 12),

              // Title (center)
              const Expanded(
                child: Text(
                  "Home",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Right actions
              Row(
                children: [
                  _buildHeaderBadge("Low"),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFF3F4F6),
                    child: Icon(Icons.person_outline,
                        size: 18, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFECACA))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
