import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/stock_controller.dart';

class StockView extends GetView<StockController> {
  const StockView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isMobile),
              const SizedBox(height: 24),
              _buildFilterSection(isMobile),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredStocks.isEmpty) {
                    return _buildEmptyState();
                  }

                  return isMobile ? _buildMobileList() : _buildDesktopTable();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sticky_note_2_outlined, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stock Management",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  "Monitor and adjust inventory levels",
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0F3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search items...",
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) {}, // Add search logic here
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text("All Categories", style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down, size: 18),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0F3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text("ITEM NAME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("CATEGORY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("IN STOCK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("UNIT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text("ACTIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: controller.filteredStocks.map((stock) {
            return DataRow(cells: [
              DataCell(Text(stock.name ?? "—", style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(stock.category ?? "—")),
              DataCell(Text(stock.quantity.toString())),
              DataCell(Text(stock.unit ?? "—")),
              DataCell(_buildStatusBadge(stock.quantity)),
              DataCell(Row(
                children: [
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () {}),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      itemCount: controller.filteredStocks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stock = controller.filteredStocks[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E0F3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stock.name ?? "—", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(stock.category ?? "—", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                  _buildStatusBadge(stock.quantity),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Quantity", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text("${stock.quantity} ${stock.unit}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(double quantity) {
    Color color;
    String label;
    if (quantity <= 10) {
      color = Colors.red;
      label = "Critical";
    } else if (quantity <= 30) {
      color = Colors.orange;
      label = "Low";
    } else {
      color = Colors.green;
      label = "In Stock";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No Items in Stock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Items will appear here once added", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
