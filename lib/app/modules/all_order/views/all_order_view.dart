import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading.dart';
import '../../../data/models/order_model.dart';
import '../../../routes/app_routes.dart';
import '../../order_management/utils/order_management_utils.dart';
import '../../order_management/widgets/order_management_date_range_field.dart';
import '../../order_management/widgets/order_management_page_scaffold.dart';
import '../../order_management/widgets/order_management_search_field.dart';
import '../../order_management/widgets/order_management_tabs.dart';
import '../controllers/all_order_controller.dart';

class AllOrderView extends GetView<AllOrderController> {
  const AllOrderView({
    super.key,
    this.embedInShell = false,
  });

  final bool embedInShell;

  @override
  Widget build(BuildContext context) {
    final content = Obx(() {
      if (controller.isLoading.value) {
        return const LoaderWebView();
      }

      final orders = controller.filteredOrders;

      return Column(
        children: [
          _AllOrderFilterBar(
            controller: controller,
            filteredCount: orders.length,
            totalCount: controller.orders.length,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: orders.isEmpty
                ? const _AllOrderEmptyState()
                : RefreshIndicator(
                    onRefresh: controller.fetchOrders,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _OrderCard(
                          order: orders[index],
                          controller: controller,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      );
    });

    if (embedInShell) {
      return content;
    }

    return OrderManagementPageScaffold(
      activeIndex: 2,
      currentSection: OrderManagementSection.allOrder,
      onSectionSelected: _navigateToSection,
      title: 'All Orders',
      subtitle: 'Manage confirmed event bookings and final settlements',
      icon: Icons.assignment_outlined,
      child: content,
    );
  }

  void _navigateToSection(OrderManagementSection section) {
    switch (section) {
      case OrderManagementSection.quotation:
        Get.offAllNamed(Routes.QUOTATION);
        break;
      case OrderManagementSection.allOrder:
        Get.offAllNamed(Routes.ALL_ORDER);
        break;
      case OrderManagementSection.invoice:
        Get.offAllNamed(Routes.INVOICE);
        break;
      case OrderManagementSection.eventSummary:
        Get.offAllNamed(Routes.EVENT_SUMMARY);
        break;
    }
  }
}

class _AllOrderFilterBar extends StatelessWidget {
  const _AllOrderFilterBar({
    required this.controller,
    required this.filteredCount,
    required this.totalCount,
  });

  final AllOrderController controller;
  final int filteredCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasDateRange = controller.startDate.value != null ||
          controller.endDate.value != null;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$filteredCount${filteredCount == totalCount ? '' : ' of $totalCount'} order${filteredCount == 1 ? '' : 's'}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            OrderManagementSearchField(
              controller: controller.searchController,
              onChanged: controller.setSearchQuery,
              hasValue: controller.searchQuery.value.isNotEmpty,
              onClear: controller.clearSearch,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickFilterChip(
                  label: 'Today',
                  onTap: () => controller.applyQuickFilter('today'),
                ),
                _QuickFilterChip(
                  label: 'This Week',
                  onTap: () => controller.applyQuickFilter('thisWeek'),
                ),
                _QuickFilterChip(
                  label: 'This Month',
                  onTap: () => controller.applyQuickFilter('thisMonth'),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: OrderManagementDateRangeField(
                    label: hasDateRange
                        ? '${OrderManagementUtils.formatDateValue(controller.startDate.value)} - ${OrderManagementUtils.formatDateValue(controller.endDate.value)}'
                        : 'Select event date range',
                    onTap: () => controller.pickDateRange(context),
                    hasValue: hasDateRange,
                    onClear: hasDateRange ? controller.clearDateRange : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      onPressed: onTap,
      backgroundColor: const Color(0xFFF3F4F6),
      side: BorderSide.none,
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.controller,
  });

  final OrderModel order;
  final AllOrderController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    order.displayInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((order.reference ?? '').isNotEmpty)
                        Text(
                          'Ref: ${order.reference}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    order.formattedEventDateSummary,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.mobileNo?.isNotEmpty == true
                            ? order.mobileNo!
                            : '—',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => controller.showOrderDetails(context, order),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F4FB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Sessions: ${order.totalSessions}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'View Details',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Estimated Persons: ${order.totalEstimatedPersons}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pending Amount: ${OrderManagementUtils.formatCurrency(order.remainingAmount)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _CardActionButton(
                      label: 'Complete',
                      icon: Icons.check_circle_outline,
                      onTap: () => controller.completeOrder(context, order),
                    ),
                    _CardActionButton(
                      label: 'Share',
                      icon: Icons.share_outlined,
                      onTap: () => controller.shareOrder(order),
                    ),
                    _CardActionButton(
                      label: 'PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      onTap: () => controller.previewOrder(order),
                    ),
                    _CardActionButton(
                      label: 'Cancel',
                      icon: Icons.cancel_outlined,
                      backgroundColor: const Color(0xFFFEE2E2),
                      foregroundColor: const Color(0xFFDC2626),
                      onTap: () => controller.cancelOrder(order),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primaryLight;
    final fg = foregroundColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllOrderEmptyState extends StatelessWidget {
  const _AllOrderEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined,
              size: 52, color: Colors.amber.shade500),
          const SizedBox(height: 14),
          const Text(
            'No orders found for the selected filters.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or event date range.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
