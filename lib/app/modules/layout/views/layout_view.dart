import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trayza_app/app/data/services/auth_service.dart';
import 'package:trayza_app/app/modules/expense/bindings/expense_binding.dart';
import 'package:trayza_app/app/core/widgets/business_logo.dart';
import 'package:trayza_app/app/data/services/business_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/layout_controller.dart';

// Import all views and bindings for direct navigation
import '../../booking/views/booking_view.dart';
import '../../booking/bindings/booking_binding.dart';
import '../../stock/views/stock_view.dart';
import '../../stock/bindings/stock_binding.dart';
import '../../category/views/category_view.dart';
import '../../category/bindings/category_binding.dart';
import '../../people/views/people_view.dart';
import '../../people/bindings/people_binding.dart';
import '../../expense/views/expense_view.dart';
import '../../payment_history/views/payment_history_view.dart';
import '../../payment_history/bindings/payment_history_binding.dart';
import '../../create_ingredient/views/create_ingredient_view.dart';
import '../../create_ingredient/controllers/create_ingredient_controller.dart';
import '../../ground_checklist/bindings/ground_checklist_binding.dart';
import '../../ground_checklist/views/ground_checklist_view.dart';

class LayoutView extends GetView<LayoutController> {
  final Widget child;
  final int activeIndex; // To highlight the active menu item
  final String headerTitle;

  const LayoutView({
    super.key,
    required this.child,
    this.activeIndex = -1,
    this.headerTitle = 'Home',
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = context.width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
              child: _buildBrandLogo(),
            ),

            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                      'Order Management',
                      Icons.assignment_outlined,
                      () => Get.offAllNamed(Routes.QUOTATION)),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      3,
                      'Stock',
                      Icons.shopping_bag_outlined,
                      () => Get.offAll(() => const StockView(),
                          binding: StockBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      4,
                      'Payment History',
                      Icons.history_rounded,
                      () => Get.offAll(() => const PaymentHistoryView(),
                          binding: PaymentHistoryBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      5,
                      'Expense',
                      Icons.payments_outlined,
                      () => Get.offAll(() => const ExpenseView(),
                          binding: ExpenseBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      6,
                      'Create Ingredient',
                      Icons.note_add_outlined,
                      () => Get.offAll(() => const CreateIngredientView(),
                          binding: CreateIngredientBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      7,
                      'People',
                      Icons.people_outline_rounded,
                      () => Get.offAll(() => const PeopleView(),
                          binding: PeopleBinding())),
                  const SizedBox(height: 10),
                  _buildSidebarItem(
                      8,
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

  Widget _buildBrandLogo() {
    return BusinessLogo(
      logoUrl: Get.isRegistered<BusinessProfileService>()
          ? BusinessProfileService.to.logoUrl
          : null,
      height: 100,
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
                        color: AppColors.primary.withValues(alpha: 0.3),
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
      decoration: BoxDecoration(
        color: AppColors.primary,
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
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 12),

              // Title (center)
              Expanded(
                child: Text(
                  headerTitle,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Right actions
              Row(
                children: [
                  _buildHeaderBadge("Low"),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 10,
                    offset: const Offset(0, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onSelected: _handleProfileMenuSelection,
                    itemBuilder: (context) => [
                      _buildProfileMenuItem(
                        value: 'users',
                        label: 'Users',
                        icon: Icons.people_alt_outlined,
                      ),
                      const PopupMenuDivider(height: 1),
                      _buildProfileMenuItem(
                        value: 'settings',
                        label: 'Settings',
                        icon: Icons.settings_outlined,
                      ),
                      const PopupMenuDivider(height: 1),
                      _buildProfileMenuItem(
                        value: 'logout',
                        label: 'Logout',
                        icon: Icons.logout_rounded,
                        color: const Color(0xFFEF4444),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFF3F4F6),
                        child: Icon(Icons.person_outline,
                            size: 18, color: Colors.grey),
                      ),
                    ),
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

  void _handleProfileMenuSelection(String value) {
    switch (value) {
      case 'users':
        Get.offAllNamed(Routes.USERS);
        break;
      case 'settings':
        Get.offAllNamed(Routes.SETTINGS);
        break;
      case 'logout':
        AuthService.to.logout();
        break;
    }
  }

  PopupMenuItem<String> _buildProfileMenuItem({
    required String value,
    required String label,
    required IconData icon,
    Color? color,
  }) {
    final itemColor = color ?? const Color(0xFF4B5563);

    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Row(
        children: [
          Icon(icon, size: 20, color: itemColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: itemColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
