import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/all_order_controller.dart';

class AllOrderView extends GetView<AllOrderController> {
  const AllOrderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isMobile),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoaderWebView();
                  }

                  if (controller.orders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      childAspectRatio: isMobile ? 1.4 : 1.8,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: controller.orders.length,
                    itemBuilder: (context, index) {
                      final order = controller.orders[index];
                      return _buildOrderCard(order);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  child: Icon(Icons.assignment_outlined,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "All Orders",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    Obx(() => Text(
                          "${controller.orders.length} orders found",
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Search & Quick Filters (Single row layout from React)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E0F3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search name or mobile...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                  onChanged: (v) {},
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 12),
                _buildQuickFilter("Today"),
                const SizedBox(width: 8),
                _buildQuickFilter("This Week"),
                const SizedBox(width: 8),
                _buildQuickFilter("Upcoming"),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilter(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563))),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E0F3)),
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (order.name ?? "?")[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.name ?? "—",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      if (order.reference != null)
                        Text("Ref: ${order.reference}",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEDE7F6))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 10, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(order.eventDate ?? "—",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Card Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEDE7F6))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(order.mobileNo ?? "—",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Detailed Order Summary Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEDE7F6))),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment_outlined,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const Text("Total Sessions",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Icon(Icons.chevron_right,
                                size: 16, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 22),
                            Text(
                                "Total Estimated Persons: ${order.estimatedPersons ?? 0}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEDE7F6)))),
            child: Row(
              children: [
                _buildActionBtn(
                    Icons.check_circle_outline, "Complete", Colors.green),
                const SizedBox(width: 8),
                _buildActionBtn(Icons.share_outlined, "Share", Colors.blue),
                const SizedBox(width: 8),
                _buildActionBtn(
                    Icons.picture_as_pdf_outlined, "PDF", Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No Orders Found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const Text("Orders will appear here once created",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
