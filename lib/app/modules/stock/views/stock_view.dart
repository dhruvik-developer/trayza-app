import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/stock_controller.dart';

class StockView extends GetView<StockController> {
  const StockView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 600;
    return LayoutView(
      activeIndex: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
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
                _buildHeader(isMobile),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Expanded(
                    child: Column(
                      children: [
                        _buildControlsBar(isMobile),
                        const SizedBox(height: 24),
                        _buildStatsSummary(isMobile),
                        const SizedBox(height: 24),
                        Expanded(child: _buildItemsGrid(context)),
                      ],
                    ),
                  );
                }),
              ],
            ),
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
          child: Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: isMobile ? 18 : 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Stocks", style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text("Manage your inventory levels", style: TextStyle(fontSize: isMobile ? 12 : 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlsBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0F3)),
      ),
      child: isMobile 
        ? Column(
            children: [
              _buildCategoryDropdown(double.infinity),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildBtn("Add Category", true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBtn("Add Item", false)),
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryDropdown(200),
              Row(
                children: [
                  _buildBtn("Add Category", true),
                  const SizedBox(width: 8),
                  _buildBtn("Add Item", false),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildCategoryDropdown(double width) {
    return Container(
      width: width,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedCategoryId.value,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: [
            const DropdownMenuItem(value: "all_items", child: Text("All Items")),
            const DropdownMenuItem(value: "low_stock", child: Text("Low Stock")),
            ...controller.categories.map((cat) => DropdownMenuItem(
              value: cat.id.toString(),
              child: Text(cat.name ?? ""),
            )),
          ],
          onChanged: controller.onCategoryChanged,
        ),
      ),
    );
  }

  Widget _buildBtn(String label, bool isPrimary) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColors.primary,
        side: isPrimary ? null : const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatsSummary(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildStatCard("Total Items", controller.totalItems.value.toString(), Icons.inventory_rounded, const [Color(0xFF845CBD), Color(0xFF6A3FAF)]),
          const SizedBox(height: 8),
          _buildStatCard(controller.lowStockItems.value > 0 ? "Low Stock" : "All Good", controller.lowStockItems.value.toString(), Icons.warning_amber_rounded, [const Color(0xFFEF4444), const Color(0xFFDC2626)]),
          const SizedBox(height: 8),
          _buildStatCard("Total Value", "₹${controller.totalValue.value.toStringAsFixed(0)}", Icons.currency_rupee_rounded, const [Color(0xFFF59E0B), Color(0xFFD97706)]),
        ],
      );
    }
    return Row(
      children: [
        _buildStatCard("Total Items", controller.totalItems.value.toString(), Icons.inventory_rounded, const [Color(0xFF845CBD), Color(0xFF6A3FAF)]),
        const SizedBox(width: 16),
        _buildStatCard(controller.lowStockItems.value > 0 ? "Low Stock" : "All Good", controller.lowStockItems.value.toString(), Icons.warning_amber_rounded, controller.lowStockItems.value > 0 ? [const Color(0xFFEF4444), const Color(0xFFDC2626)] : [const Color(0xFF10B981), const Color(0xFF059669)]),
        const SizedBox(width: 16),
        _buildStatCard("Total Value", "₹${controller.totalValue.value.toStringAsFixed(0)}", Icons.currency_rupee_rounded, const [Color(0xFFF59E0B), Color(0xFFD97706)]),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Expanded(
      flex: Get.width < 600 ? 0 : 1, // Only expand on desktop
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            Icon(icon, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context) {
    if (controller.items.isEmpty) return _buildEmptyState();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: context.width < 600 ? 280 : 320,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.items.length,
      itemBuilder: (context, index) => _buildStockCard(controller.items[index]),
    );
  }

  Widget _buildStockCard(dynamic item) {
    double qty = double.tryParse(item.quantity ?? "0") ?? 0;
    double alert = double.tryParse(item.alert ?? "0") ?? 0;
    bool isLow = qty <= alert;
    double percent = alert > 0 ? (qty / (alert * 4)).clamp(0.0, 1.0) : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: isLow ? const Color(0xFFFEF2F2) : const Color(0xFFFAF8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLow ? const Color(0xFFFECACA) : const Color(0xFFE8E0F3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: isLow ? const Color(0xFFFEE2E2) : const Color(0xFFF4EFFC), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.inventory_2_outlined, color: isLow ? Colors.red : AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                      Text("${item.quantity} ${item.type ?? ""}", style: TextStyle(fontWeight: FontWeight.bold, color: isLow ? Colors.red : AppColors.primary, fontSize: 12)),
                    ],
                  ),
                ),
                if (isLow) const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(value: percent, backgroundColor: Colors.grey[200], color: isLow ? Colors.red : AppColors.primary, minHeight: 6),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _buildActionBtn("Add", Icons.add, const Color(0xFFF4EFFC), AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: _buildActionBtn("Remove", Icons.remove, const Color(0xFFFEF2F2), Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No Items Available", style: TextStyle(color: Colors.grey)));
  }
}
