import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';

class PeopleView extends StatelessWidget {
  const PeopleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 600;

    return LayoutView(
      activeIndex: 9,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildTabCard(
                      context,
                      title: "Event Staff",
                      description:
                          "Manage staff profiles, roles, and staffing rates.",
                      icon: Icons.people_outline_rounded,
                      onTap: () {
                        // TODO: Navigate to Staff Management
                        Get.snackbar("Coming Soon",
                            "Staff Management implementation in progress");
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTabCard(
                      context,
                      title: "Vendors",
                      description:
                          "Track suppliers and category-wise vendor pricing.",
                      icon: Icons.local_shipping_outlined,
                      onTap: () {
                        // TODO: Navigate to Vendor Management
                        Get.snackbar("Coming Soon",
                            "Vendor Management implementation in progress");
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTabCard(
                      context,
                      title: "Waiter Types",
                      description:
                          "Define waiter categories and per-person pricing.",
                      icon: Icons.work_outline_rounded,
                      onTap: () {
                        // TODO: Navigate to Waiter Type Management
                        Get.snackbar("Coming Soon",
                            "Waiter Type Management implementation in progress");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.people_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("People & CRM",
                style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text("Manage your internal team and external partners",
                style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildTabCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDE7F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
