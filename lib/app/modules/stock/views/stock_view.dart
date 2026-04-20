import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/stock_controller.dart';

class StockView extends GetView<StockController> {
  const StockView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutView(
      activeIndex: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
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
                _buildHeader(),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Expanded(
                    child: Column(
                      children: [
                        _buildControlsBar(),
                        const SizedBox(height: 24),
                        _buildStatsSummary(),
                        const SizedBox(height: 24),
                        Expanded(child: _buildItemsGrid()),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Stocks", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text("Manage your inventory & stock levels", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0F3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 200,
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
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Add Category"),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Add Item"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Row(
      children: [
        _buildStatCard(
          "Total Items",
          controller.totalItems.value.toString(),
          Icons.inventory_rounded,
          const [Color(0xFF845CBD), Color(0xFF6A3FAF)],
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          controller.lowStockItems.value > 0 ? "Low Stock" : "All Good",
          controller.lowStockItems.value.toString(),
          Icons.warning_amber_rounded,
          controller.lowStockItems.value > 0 
            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)] 
            : [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          "Total Value",
          "₹${controller.totalValue.value.toStringAsFixed(0)}",
          Icons.currency_rupee_rounded,
          const [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid() {
    if (controller.items.isEmpty) {
      return _buildEmptyState();
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 320,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        return _buildStockCard(controller.items[index]);
      },
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isLow ? const Color(0xFFFEE2E2) : const Color(0xFFF4EFFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: isLow ? Colors.red : AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, overflow: TextOverflow.ellipsis)),
                      if (item.categoryName != null)
                        Text(item.categoryName!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text("${item.quantity} ${item.type ?? ""}", style: TextStyle(fontWeight: FontWeight.bold, color: isLow ? Colors.red : AppColors.primary)),
                    ],
                  ),
                ),
                if (isLow)
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      const Text("LOW", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.grey[200],
                  color: isLow ? Colors.red : (percent > 0.6 ? Colors.emerald : Colors.amber),
                  minHeight: 8,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("STOCK LEVEL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text("Min: ${item.alert}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildPriceCard("Net Price", "₹${item.ntePrice}"),
                const SizedBox(width: 8),
                _buildPriceCard("Total Value", "₹${item.totalPrice}", isValue: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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

  Widget _buildPriceCard(String label, String value, {bool isValue = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.05))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isValue ? Colors.emerald : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: text),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text("No Items Available", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
