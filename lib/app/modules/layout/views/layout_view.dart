import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trayza_app/app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/layout_controller.dart';

// Import all views and bindings for direct navigation
import '../../booking/views/booking_view.dart';
import '../../booking/bindings/booking_binding.dart';
import '../../all_order/views/all_order_view.dart';
import '../../all_order/bindings/all_order_binding.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../dashboard/bindings/dashboard_binding.dart';
import '../../stock/views/stock_view.dart';
import '../../stock/bindings/stock_binding.dart';
import '../../item/views/item_view.dart';
import '../../item/bindings/item_binding.dart';

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
          // Desktop Sidebar
          if (isDesktop) _buildSidebar(context),

          // Main Content
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
            // Logo Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Image.asset('assets/images/logo.png',
                  height: 60,
                  errorBuilder: (_, __, ___) => const FlutterLogo(size: 60)),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSidebarItem(
                      0,
                      'Dashboard',
                      Icons.dashboard_rounded,
                      () => Get.offAll(() => const DashboardView(),
                          binding: DashboardBinding())),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                      1,
                      'All Orders',
                      Icons.assignment_rounded,
                      () => Get.offAll(() => const AllOrderView(),
                          binding: AllOrderBinding())),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                      2,
                      'Create Dish',
                      Icons.restaurant_menu_rounded,
                      () => Get.offAll(() => const BookingView(),
                          binding: BookingBinding())),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                      3,
                      'Stocks',
                      Icons.inventory_2_rounded,
                      () => Get.offAll(() => const StockView(),
                          binding: StockBinding())),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Divider(color: AppColors.border),
                  ),
                  _buildSidebarItem(
                      5, 'Expense', Icons.payments_rounded, () {}),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                      6, 'Settings', Icons.settings_rounded, () {}),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), // rounded-xl
            color: isActive ? AppColors.primary : Colors.transparent,
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon Container
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
                              blurRadius: 2,
                              offset: Offset(0, 1))
                        ],
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textSecondary,
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
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
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
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              if (!isSmallMobile) ...[
                const Icon(Icons.home_outlined,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white30, size: 16),
                const SizedBox(width: 8),
                const Text("Trayza Admin",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
              const Spacer(),
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                child: Text("A",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color bg) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: text.isEmpty ? 10 : 12, vertical: 8),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          if (text.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}
