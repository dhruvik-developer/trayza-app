import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading.dart';
import '../../../data/models/invoice_model.dart';
import '../../../routes/app_routes.dart';
import '../../order_management/utils/order_management_utils.dart';
import '../../order_management/widgets/order_management_page_scaffold.dart';
import '../../order_management/widgets/order_management_search_field.dart';
import '../../order_management/widgets/order_management_tabs.dart';
import '../controllers/invoice_controller.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({
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

      final invoices = controller.filteredInvoices;

      return RefreshIndicator(
        onRefresh: controller.fetchInvoices,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _InvoiceFilterBar(
                controller: controller,
                filteredCount: invoices.length,
                totalCount: controller.invoices.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (invoices.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _InvoiceEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _InvoiceCard(
                        invoice: invoices[index],
                        controller: controller,
                      ),
                    ),
                    childCount: invoices.length,
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
      currentSection: OrderManagementSection.invoice,
      onSectionSelected: _navigateToSection,
      title: 'Invoice',
      subtitle: 'Track billing, settlements, and client-ready bill sharing',
      icon: Icons.receipt_long_outlined,
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

class _InvoiceFilterBar extends StatelessWidget {
  const _InvoiceFilterBar({
    required this.controller,
    required this.filteredCount,
    required this.totalCount,
  });

  final InvoiceController controller;
  final int filteredCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final hasDateRange =
        controller.startDate.value != null || controller.endDate.value != null;

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
            '$filteredCount${filteredCount == totalCount ? '' : ' of $totalCount'} invoice${filteredCount == 1 ? '' : 's'}',
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
            crossAxisAlignment: WrapCrossAlignment.center,
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
              OutlinedButton.icon(
                onPressed: () => controller.pickDateRange(context),
                icon: const Icon(Icons.date_range_outlined, size: 18),
                label: Text(
                  hasDateRange
                      ? '${OrderManagementUtils.formatDateValue(controller.startDate.value)} - ${OrderManagementUtils.formatDateValue(controller.endDate.value)}'
                      : 'Select event date range',
                ),
              ),
              if (hasDateRange)
                TextButton(
                  onPressed: controller.clearDateRange,
                  child: const Text('Clear'),
                ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  value: controller.selectedFilter.value,
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
                  items: controller.filterOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: controller.updateFilter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.controller,
  });

  final InvoiceModel invoice;
  final InvoiceController controller;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(invoice.paymentStatus);
    final isPaid = invoice.isPaid;
    final pendingAmount = invoice.displayPendingAmount;
    final totalReceived = invoice.advanceAmount +
        invoice.transactionAmount +
        invoice.settlementAmount;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    invoice.booking.displayInitial,
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
                        invoice.booking.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        invoice.eventDateSummary,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (invoice.billNo.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Bill No: ${invoice.billNo}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    invoice.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoPill(
                      icon: Icons.phone_outlined,
                      label: invoice.booking.mobileNo?.isNotEmpty == true
                          ? invoice.booking.mobileNo!
                          : 'No mobile number',
                    ),
                    _InfoPill(
                      icon: Icons.credit_card_outlined,
                      label: invoice.paymentMode.isNotEmpty
                          ? invoice.paymentMode
                          : 'Payment mode unavailable',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Total Amount',
                        value: OrderManagementUtils.formatCurrency(
                          invoice.totalAmount,
                        ),
                        emphasize: true,
                      ),
                      _SummaryRow(
                        label: 'Advance Amount',
                        value: OrderManagementUtils.formatCurrency(
                          invoice.advanceAmount,
                        ),
                      ),
                      _SummaryRow(
                        label: 'Transaction Amount',
                        value: OrderManagementUtils.formatCurrency(
                          invoice.transactionAmount,
                        ),
                      ),
                      _SummaryRow(
                        label: 'Settlement Amount',
                        value: OrderManagementUtils.formatCurrency(
                          invoice.settlementAmount,
                        ),
                      ),
                      _SummaryRow(
                        label: 'Total Received',
                        value: OrderManagementUtils.formatCurrency(
                          totalReceived,
                        ),
                      ),
                      if (!isPaid) ...[
                        const Divider(height: 22),
                        _SummaryRow(
                          label: 'Pending Amount',
                          value: OrderManagementUtils.formatCurrency(
                            pendingAmount,
                          ),
                          valueColor: AppColors.error,
                          emphasize: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _CardActionButton(
                      label: 'View Order',
                      icon: Icons.visibility_outlined,
                      onTap: () => controller.previewOrderCopy(invoice),
                    ),
                    if (!isPaid)
                      _CardActionButton(
                        label: 'Complete Payment',
                        icon: Icons.check_circle_outline,
                        onTap: () =>
                            controller.completePayment(context, invoice),
                      ),
                    _CardActionButton(
                      label: 'Send Bill',
                      icon: Icons.send_outlined,
                      onTap: () => controller.shareBill(invoice),
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

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return AppColors.success;
      case 'PARTIAL':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: AppColors.textSecondary,
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
    );
    final valueStyle = TextStyle(
      color: valueColor ?? AppColors.textPrimary,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
      fontSize: emphasize ? 15 : 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(value, style: valueStyle),
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

class _InvoiceEmptyState extends StatelessWidget {
  const _InvoiceEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 52,
            color: Colors.amber.shade500,
          ),
          const SizedBox(height: 14),
          const Text(
            'No invoices found for the selected filters.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting the payment status, search, or event date range.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
