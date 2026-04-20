import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/layout_controller.dart';

// Import all views and bindings for direct navigation
import '../../booking/views/booking_view.dart';
import '../../booking/bindings/booking_binding.dart';
import '../../all_order/views/all_order_view.dart';
import '../../all_order/bindings/all_order_binding.dart';
import '../../stock/views/stock_view.dart';
import '../../stock/bindings/stock_binding.dart';
import '../../item/views/item_view.dart';
import '../../item/bindings/item_binding.dart';
import '../../people/views/people_view.dart';
// import '../../people/bindings/people_binding.dart';

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
                _buildHeader(context, isDesktop),
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
            // Logo Section (Matches React UI Style)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Image.asset('assets/images/logo.png',
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const FlutterLogo(size: 60)),
            ),

            // Scrollable Menu Items (Exact List from Image)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildSidebarItem(0, 'Create Dish', Icons.room_service_outlined, 
                      () => Get.offAll(() => const BookingView(), binding: BookingBinding())),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(1, 'Category', Icons.category_outlined, () {}),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(2, 'Quotation', Icons.edit_note_rounded, () {}),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(3, 'All Order', Icons.checklist_rtl_rounded, 
                      () => Get.offAll(() => const AllOrderView(), binding: AllOrderBinding())),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(4, 'Invoice', Icons.receipt_outlined, () {}),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(5, 'GST Billing', Icons.receipt_long_outlined, () {}),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(6, 'Stock', Icons.shopping_bag_outlined, 
                      () => Get.offAll(() => const StockView(), binding: StockBinding())),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(7, 'Payment History', Icons.history_rounded, () {}),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(8, 'Expense', Icons.payments_outlined, () {}),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(9, 'Create Ingredient', Icons.note_add_outlined, () {}),
                  const SizedBox(height: 10),
                  
                  // _buildSidebarItem(10, 'People', Icons.people_outline_rounded, 
                  //     () => Get.offAll(() => const PeopleView(), binding: PeopleBinding())),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(11, 'Event Summary', Icons.description_outlined, () {}),
                  const SizedBox(height: 10),
                  
                  _buildSidebarItem(12, 'Ground Checklist', Icons.rule_folder_outlined, () {}),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon, VoidCallback onTap) {
    bool isActive = activeIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), // Replicating the rounded corners in image
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
              // Icon Container with White Box logic from Image
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive ? null : [
                    const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    bool isSmallMobile = context.width < 400;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 12 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              if (!isDesktop)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.primary),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              if (!isSmallMobile) ...[
                const Icon(Icons.home_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                const Text("Home", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
              const Spacer(),
              _buildHeaderBadge("Low Stock"),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF3F4F6),
                child: Icon(Icons.person_outline, size: 20, color: Colors.grey),
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
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFECACA))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
