import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/all_order_controller.dart';

class AllOrderView extends GetView<AllOrderController> {
  const AllOrderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutView(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.orders.isEmpty) {
                      return _buildEmptyState();
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 600,
                        mainAxisExtent: 260,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: controller.orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(context, controller.orders[index]);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("All Orders", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Obx(() => Text("${controller.orders.length} orders", style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
              ],
            ),
          ],
        ),
        // Search & Filter (To be implemented)
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0F3)),
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF4EFFC),
              border: Border(bottom: BorderSide(color: Color(0xFFEDE7F6))),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (order['name'] as String? ?? "?").substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order['name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (order['reference'] != null)
                          Text("Ref: ${order['reference']}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEDE7F6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(order['event_date'] ?? "No Date", style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Card Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEDE7F6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(order['mobile_no'] ?? "--", style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF), // bg-indigo-50/40
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEDE7F6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.assignment_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text("Total Sessions: ${order['sessions']?.length ?? 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Card Footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildActionButton("Complete", Icons.check_circle_outline, const Color(0xFFECFDF5), const Color(0xFF059669)),
                const SizedBox(width: 8),
                _buildActionButton("Share", Icons.share_outlined, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                _buildActionButton("PDF", Icons.picture_as_pdf_outlined, const Color(0xFFF5F3FF), AppColors.primary),
                const SizedBox(width: 8),
                _buildActionButton("Cancel", Icons.cancel_outlined, const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bg, Color text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: text),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
          SizedBox(height: 12),
          Text("No Orders Available", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          Text("Orders will appear here once created", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
