import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutView(
      activeIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: controller.fetchStats,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard Overview",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 24),
                Obx(() => GridView.count(
                  crossAxisCount: context.width > 1200 ? 4 : (context.width > 600 ? 2 : 1),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      "Total Orders",
                      controller.totalOrders.value.toString(),
                      Icons.shopping_bag_rounded,
                      AppColors.primary,
                    ),
                    _buildStatCard(
                      context,
                      "Pending Orders",
                      controller.pendingOrders.value.toString(),
                      Icons.pending_actions_rounded,
                      AppColors.warning,
                    ),
                    _buildStatCard(
                      context,
                      "Total Revenue",
                      "₹${NumberFormat('#,##,###').format(controller.totalRevenue.value)}",
                      Icons.account_balance_wallet_rounded,
                      AppColors.success,
                    ),
                    _buildStatCard(
                      context,
                      "Active Staff",
                      "12", // Mocked for now
                      Icons.people_rounded,
                      AppColors.info,
                    ),
                  ],
                )),
                const SizedBox(height: 32),
                Text(
                  "Recent Activity",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Placeholder(
                      fallbackHeight: 200,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Center(child: Text("Quick Actions & Recent Orders Table")),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
