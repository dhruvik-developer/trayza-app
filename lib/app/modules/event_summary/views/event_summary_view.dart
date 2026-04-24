import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading.dart';
import '../../../data/models/event_summary_model.dart';
import '../../../routes/app_routes.dart';
import '../../order_management/utils/order_management_utils.dart';
import '../../order_management/widgets/order_management_page_scaffold.dart';
import '../../order_management/widgets/order_management_tabs.dart';
import '../controllers/event_summary_controller.dart';

class EventSummaryView extends GetView<EventSummaryController> {
  const EventSummaryView({
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

      final summaries = [...controller.summaries]
        ..sort((a, b) => b.events.length.compareTo(a.events.length));
      final totalPending = summaries.fold<double>(
        0,
        (sum, item) => sum + item.totalPending,
      );
      final totalEvents = summaries.fold<int>(
        0,
        (sum, item) => sum + item.events.length,
      );

      return RefreshIndicator(
        onRefresh: controller.fetchSummary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _SummaryHeader(
                controller: controller,
                staffCount: summaries.length,
                eventCount: totalEvents,
                totalPending: totalPending,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (summaries.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EventSummaryEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _StaffSummaryCard(
                        summary: summaries[index],
                        controller: controller,
                      ),
                    ),
                    childCount: summaries.length,
                  ),
                ),
              ),
          ],
        ),
      );
    });

    if (embedInShell) {
      return content;
    }

    return OrderManagementPageScaffold(
      activeIndex: 2,
      currentSection: OrderManagementSection.eventSummary,
      onSectionSelected: _navigateToSection,
      title: 'Event Summary',
      subtitle:
          'Monitor staffing totals, payment status, and assignment-level dues',
      icon: Icons.bar_chart_rounded,
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

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.controller,
    required this.staffCount,
    required this.eventCount,
    required this.totalPending,
  });

  final EventSummaryController controller;
  final int staffCount;
  final int eventCount;
  final double totalPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Grouped event staffing summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: controller.selectedStaffType.value,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: controller.staffTypeOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: controller.updateStaffType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                label: 'Staff Members',
                value: staffCount.toString(),
                icon: Icons.people_outline_rounded,
              ),
              _StatCard(
                label: 'Assignments',
                value: eventCount.toString(),
                icon: Icons.event_note_outlined,
              ),
              _StatCard(
                label: 'Pending Payments',
                value: OrderManagementUtils.formatCurrency(totalPending),
                icon: Icons.account_balance_wallet_outlined,
                valueColor:
                    totalPending > 0 ? AppColors.error : AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width < 700 ? double.infinity : 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffSummaryCard extends StatelessWidget {
  const _StaffSummaryCard({
    required this.summary,
    required this.controller,
  });

  final EventSummaryModel summary;
  final EventSummaryController controller;

  @override
  Widget build(BuildContext context) {
    final isFixedStaff = summary.staffType.toLowerCase() == 'fixed';

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
                    summary.staffName.trim().isEmpty
                        ? '?'
                        : summary.staffName.trim()[0].toUpperCase(),
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
                        summary.staffName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${summary.events.length} assignment${summary.events.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
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
                    summary.staffType,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: isFixedStaff
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Fixed staff are usually settled through monthly payroll, so assignment-level amounts are not tracked here.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _SummaryLine(
                              label: 'Total Amount',
                              value: OrderManagementUtils.formatCurrency(
                                summary.totalAmount,
                              ),
                            ),
                            _SummaryLine(
                              label: 'Paid',
                              value: OrderManagementUtils.formatCurrency(
                                summary.totalPaid,
                              ),
                              valueColor: AppColors.success,
                            ),
                            _SummaryLine(
                              label: 'Pending',
                              value: OrderManagementUtils.formatCurrency(
                                summary.totalPending,
                              ),
                              valueColor: summary.totalPending > 0
                                  ? AppColors.error
                                  : AppColors.success,
                              emphasize: true,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ActionButton(
                    label: 'View Details',
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _showStaffDetails(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStaffDetails(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summary.staffName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${summary.staffType} staff • ${summary.events.length} assignment${summary.events.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        _DialogMetric(
                          label: 'Total Amount',
                          value: OrderManagementUtils.formatCurrency(
                            summary.totalAmount,
                          ),
                        ),
                        _DialogMetric(
                          label: 'Paid',
                          value: OrderManagementUtils.formatCurrency(
                            summary.totalPaid,
                          ),
                        ),
                        _DialogMetric(
                          label: 'Pending',
                          value: OrderManagementUtils.formatCurrency(
                            summary.totalPending,
                          ),
                          valueColor: summary.totalPending > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assignments',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: summary.events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final assignment = summary.events[index];
                        final showPayButton = assignment.canAcceptPayment &&
                            assignment.remainingAmount > 0;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          assignment.sessionName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          OrderManagementUtils
                                              .formatDisplayDate(
                                            assignment.sessionDate,
                                          ),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: assignment.remainingAmount > 0
                                          ? AppColors.error
                                              .withValues(alpha: 0.12)
                                          : AppColors.success
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      assignment.paymentStatus,
                                      style: TextStyle(
                                        color: assignment.remainingAmount > 0
                                            ? AppColors.error
                                            : AppColors.success,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _InfoTag(
                                    label:
                                        'Total ${OrderManagementUtils.formatCurrency(assignment.totalAmount)}',
                                  ),
                                  _InfoTag(
                                    label:
                                        'Paid ${OrderManagementUtils.formatCurrency(assignment.paidAmount)}',
                                  ),
                                  _InfoTag(
                                    label:
                                        'Pending ${OrderManagementUtils.formatCurrency(assignment.remainingAmount)}',
                                    textColor: assignment.remainingAmount > 0
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ],
                              ),
                              if (showPayButton) ...[
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _ActionButton(
                                    label: 'Record Payment',
                                    icon: Icons.payments_outlined,
                                    onTap: () {
                                      Navigator.of(dialogContext).pop();
                                      controller.promptPayment(
                                        context,
                                        assignment: assignment,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              fontSize: emphasize ? 15 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogMetric extends StatelessWidget {
  const _DialogMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.label,
    this.textColor,
  });

  final String label;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventSummaryEmptyState extends StatelessWidget {
  const _EventSummaryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined,
              size: 52, color: Colors.amber.shade500),
          const SizedBox(height: 14),
          const Text(
            'No summary records found for the selected staff type.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Try changing the staff filter or refresh after assignments are added.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
