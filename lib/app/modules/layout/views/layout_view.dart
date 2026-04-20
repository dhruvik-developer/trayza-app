import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../controllers/layout_controller.dart';

class LayoutView extends GetView<LayoutController> {
  const LayoutView({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      drawer: isDesktop ? null : _buildSidebar(context),
      appBar: AppBar(
        title: Text(
          "Trayza Admin",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
          _buildUserMenu(context),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.menuItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = controller.menuItems[index];
                return Obx(() {
                  final isSelected = controller.selectedIndex.value == index;
                  return ListTile(
                    onTap: () {
                      controller.setIndex(index);
                      if (MediaQuery.of(context).size.width <= 900) {
                        Get.back();
                      }
                      Get.toNamed(item['route'] as String);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      _getIcon(item['icon'] as String),
                      color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    tileColor: isSelected ? AppColors.primary : Colors.transparent,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return PopupMenuButton(
      offset: const Offset(0, 50),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            AuthService.to.username ?? "Admin",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Profile'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text('Logout', style: TextStyle(color: Colors.redAccent)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          AuthService.to.logout();
        }
      },
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'dashboard': return Icons.grid_view_rounded;
      case 'shopping_cart': return Icons.shopping_basket_rounded;
      case 'restaurant': return Icons.restaurant_menu_rounded;
      case 'category': return Icons.category_rounded;
      case 'inventory': return Icons.inventory_2_rounded;
      case 'people': return Icons.people_alt_rounded;
      case 'settings': return Icons.settings_rounded;
      default: return Icons.circle;
    }
  }
}
