import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/layout_controller.dart';
import '../../../app/routes/app_pages.dart';

class LayoutView extends GetView<LayoutController> {
  final Widget child;

  const LayoutView({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Desktop Sidebar
          if (MediaQuery.of(context).size.width > 1024) _buildSidebar(context),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      drawer: MediaQuery.of(context).size.width <= 1024 
          ? Drawer(child: _buildSidebar(context)) 
          : null,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 288, // w-72 from React
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Column(
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Image.asset('assets/images/logo.png', height: 80, errorBuilder: (_, __, ___) => 
              const FlutterLogo(size: 80)),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSidebarItem(context, 'Create Dish', Icons.restaurant_menu_rounded, Routes.DISH),
                const SizedBox(height: 16), // space-y-4
                _buildSidebarItem(context, 'Category', Icons.category_rounded, Routes.CATEGORY),
                const SizedBox(height: 16),
                _buildSidebarItem(context, 'All Orders', Icons.assignment_rounded, Routes.ALL_ORDER),
                const SizedBox(height: 16),
                _buildSidebarItem(context, 'Stock', Icons.inventory_2_rounded, Routes.STOCK),
                const SizedBox(height: 16),
                _buildSidebarItem(context, 'People', Icons.people_alt_rounded, Routes.PEOPLE),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, String title, IconData icon, String route) {
    bool isActive = Get.currentRoute == route;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), // rounded-xl
            color: isActive ? AppColors.primary : Colors.transparent,
            boxShadow: isActive ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive ? null : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive ? AppColors.primary : AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Breadcrumbs (Mock for now)
          const Row(
            children: [
              Icon(Icons.home_outlined, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 16),
              SizedBox(width: 8),
              Text(
                "Dashboard",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          // Badges & Profile
          Row(
            children: [
              _buildBadge("12 Low Stock", Icons.warning_amber_rounded, Colors.red.withOpacity(0.2)),
              const SizedBox(width: 12),
              _buildBadge("5 Upcoming", Icons.calendar_month_rounded, Colors.emerald.withOpacity(0.2)),
              const SizedBox(width: 24),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Text("A", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
