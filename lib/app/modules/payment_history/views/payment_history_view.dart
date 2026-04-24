import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading.dart';
import '../../../data/models/payment_history_model.dart';
import '../controllers/payment_history_controller.dart';
import '../../layout/views/layout_view.dart';

class PaymentHistoryView extends GetView<PaymentHistoryController> {
  const PaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: controller.fetchPaymentHistory,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  if (controller.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: LoaderWebView(),
                    )
                  else if (controller.paymentHistory.value != null)
                    _buildContent(isMobile)
                  else
                    _buildEmptyState(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12)),
          child:
              Icon(Icons.history_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payment History",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text("Track all incoming and outstanding payments",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(bool isMobile) {
    final history = controller.paymentHistory.value!;

    final summaryItems = [
      {
        "label": "Total Paid Amount",
        "value": history.totalPaidAmount,
        "color": Colors.green,
        "icon": Icons.check_circle,
      },
      {
        "label": "Total Unpaid Amount",
        "value": history.totalUnpaidAmount,
        "color": Colors.red,
        "icon": Icons.cancel,
      },
      {
        "label": "Total Settlement Amount",
        "value": history.totalSettlementAmount,
        "color": Colors.amber.shade700,
        "icon": Icons.handshake_outlined,
      },
      {
        "label": "Total Expense Amount",
        "value": history.totalExpenseAmount,
        "color": Colors.orange,
        "icon": Icons.receipt_long,
        "note":
            "Includes expense entries, event staff paid, and fixed salary paid.",
      },
    ];

    int itemsPerRow = isMobile ? 1 : 2;

    return Column(
      children: [
        _buildHeroCard(history, isMobile),
        const SizedBox(height: 16),
        ListView.builder(
          itemCount: (summaryItems.length / itemsPerRow).ceil(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            int startIndex = index * itemsPerRow;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: List.generate(itemsPerRow, (i) {
                  int itemIndex = startIndex + i;

                  if (itemIndex >= summaryItems.length) {
                    return const Expanded(child: SizedBox());
                  }

                  final item = summaryItems[itemIndex];

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: (!isMobile && i == 0) ? 16 : 0,
                      ),
                      child: _buildSummaryCard(
                        label: item["label"] as String,
                        value: item["value"] as double,
                        color: item["color"] as Color,
                        icon: item["icon"] as IconData,
                        note: item["note"] as String?,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeroCard(PaymentHistoryModel history, bool isMobile) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 140 : 172),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 28,
        vertical: isMobile ? 20 : 24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0E8AD4), Color(0xFF0B5E92)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5E92).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 52 : 64,
                height: isMobile ? 52 : 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: isMobile ? 26 : 30,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              const Text(
                "Total Balance",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: isMobile ? 4 : 2, top: 12),
            child: Text(
              _formatCurrency(history.netAmount),
              style: TextStyle(
                fontSize: isMobile ? 36 : 52,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
    String? note,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _formatCurrency(value),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 8),
            Text(
              note,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##,##0.##', 'en_IN');
    return '₹ ${formatter.format(amount)}';
  }

  Widget _buildEmptyState() {
    final message =
        controller.errorMessage.value ?? "No payment history available.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No Payment History Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: controller.fetchPaymentHistory,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
