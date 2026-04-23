import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trayza_app/app/data/models/order_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading.dart';
import '../../../routes/app_routes.dart';
import '../../order_management/utils/order_management_utils.dart';
import '../../order_management/widgets/order_management_date_range_field.dart';
import '../../order_management/widgets/order_management_page_scaffold.dart';
import '../../order_management/widgets/order_management_search_field.dart';
import '../../order_management/widgets/order_management_tabs.dart';
import '../controllers/quotation_controller.dart';

class QuotationView extends GetView<QuotationController> {
  const QuotationView({
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

      final quotations = controller.filteredQuotations;

      return Column(
        children: [
          _QuotationFilterBar(controller: controller),
          const SizedBox(height: 16),
          Expanded(
            child: quotations.isEmpty
                ? const _QuotationEmptyState()
                : RefreshIndicator(
                    onRefresh: controller.fetchQuotations,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: quotations.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _QuotationCard(
                          quotation: quotations[index],
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
      currentSection: OrderManagementSection.quotation,
      onSectionSelected: _navigateToSection,
      title: 'Quotation',
      subtitle: 'Generate and manage client quotes',
      icon: Icons.description_outlined,
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

class _QuotationFilterBar extends StatelessWidget {
  const _QuotationFilterBar({required this.controller});

  final QuotationController controller;

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
          children: [
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
                  label: 'Next 7 Days',
                  onTap: () => controller.applyQuickFilter('next7Days'),
                ),
                _QuickFilterChip(
                  label: 'Next 30 Days',
                  onTap: () => controller.applyQuickFilter('next30Days'),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: OrderManagementDateRangeField(
                    label: hasDateRange
                        ? '${OrderManagementUtils.formatDateValue(controller.startDate.value)} - ${OrderManagementUtils.formatDateValue(controller.endDate.value)}'
                        : 'Select date range',
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

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
    required this.controller,
  });

  final OrderModel quotation;
  final QuotationController controller;

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
                    quotation.displayInitial,
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
                        quotation.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((quotation.reference ?? '').isNotEmpty)
                        Text(
                          'Ref: ${quotation.reference}',
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
                    quotation.formattedEventDateSummary,
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
                      Icon(Icons.phone_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        quotation.mobileNo?.isNotEmpty == true
                            ? quotation.mobileNo!
                            : '—',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _showSessionsDialog(context, quotation),
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
                              Icons.description_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Sessions: ${quotation.totalSessions}',
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
                          'Total Estimated Persons: ${quotation.totalEstimatedPersons}',
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
                      label: 'View',
                      icon: Icons.visibility_outlined,
                      onTap: () => controller.previewQuotation(quotation),
                    ),
                    _CardActionButton(
                      label: 'Confirm',
                      icon: Icons.check_circle_outline,
                      onTap: () =>
                          controller.confirmQuotation(context, quotation),
                    ),
                    _CardActionButton(
                      label: 'Cancel',
                      icon: Icons.cancel_outlined,
                      backgroundColor: const Color(0xFFFEE2E2),
                      foregroundColor: const Color(0xFFDC2626),
                      onTap: () => controller.cancelQuotation(quotation),
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

  Future<void> _showSessionsDialog(BuildContext context, OrderModel quotation) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${quotation.name} Schedules'),
          content: SizedBox(
            width: 420,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: quotation.effectiveSessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final session = quotation.effectiveSessions[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${OrderManagementUtils.formatDisplayDate(session.eventDate)} • ${session.eventTime ?? '—'}',
                        ),
                      ),
                      Text(
                        '${session.estimatedPersons} persons',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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

class _QuotationEmptyState extends StatelessWidget {
  const _QuotationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 52, color: Colors.amber.shade500),
          const SizedBox(height: 14),
          const Text(
            'No quotations found for the selected filters.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or date range.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
