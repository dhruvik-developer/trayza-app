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
              _buildStatsSection(isMobile),
              const SizedBox(height: 24),
              _buildFilterSection(context, isMobile),
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

  Widget _buildStatsSection(bool isMobile) {
    return Obx(() => isMobile
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildStatCard(
                  "TOTAL ITEMS",
                  controller.totalItems.value.toString(),
                  [const Color(0xFF845CBD), const Color(0xFF6A3FAF)],
                  Icons.inventory_2_outlined,
                  220,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  "LOW STOCK",
                  controller.lowStockItems.value.toString(),
                  [const Color(0xFFFF4D4D), const Color(0xFFFF1A1A)],
                  Icons.warning_amber_rounded,
                  220,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  "TOTAL VALUE",
                  "₹${controller.totalValue.value.toStringAsFixed(0)}",
                  [const Color(0xFFFFB347), const Color(0xFFFF8C00)],
                  Icons.account_balance_wallet_outlined,
                  220,
                ),
              ],
            ),
          )
        : Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                "TOTAL ITEMS",
                controller.totalItems.value.toString(),
                [const Color(0xFF845CBD), const Color(0xFF6A3FAF)],
                Icons.inventory_2_outlined,
                null,
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                "LOW STOCK",
                controller.lowStockItems.value.toString(),
                [const Color(0xFFFF4D4D), const Color(0xFFFF1A1A)],
                Icons.warning_amber_rounded,
                null,
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                "TOTAL VALUE",
                "₹${controller.totalValue.value.toStringAsFixed(0)}",
                [const Color(0xFFFFB347), const Color(0xFFFF8C00)],
                Icons.account_balance_wallet_outlined,
                null,
              )),
            ],
          ));
  }

  Widget _buildStatCard(String title, String value, List<Color> colors,
      IconData icon, double? width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, bool isMobile) {
    return Column(
      children: [
        if (isMobile) ...[
          _buildCategoryDropdown(true),
          const SizedBox(height: 16),
          // Search row
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: const Color(0xFFF1F0F7)),
            ),
            child: TextField(
              onChanged: (v) => controller.onSearchChanged(v),
              decoration: const InputDecoration(
                hintText: "Search stock items...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Actions row
          Row(
            children: [
              Obx(() {
                final id = controller.selectedCategoryId.value;
                if (id == "all_items" || id == "low_stock") {
                  return const SizedBox.shrink();
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: OutlinedButton.icon(
                      onPressed: () => controller.addItem(),
                      icon: const Icon(Icons.add_box_outlined, size: 18),
                      label: const Text("Add Item"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                );
              }),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.addCategory(),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text("Add Category"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: const Color(0xFFF1F0F7)),
                  ),
                  child: TextField(
                    onChanged: (v) => controller.onSearchChanged(v),
                    decoration: const InputDecoration(
                      hintText: "Search items...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, size: 20, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildCategoryDropdown(false),
              Obx(() {
                final id = controller.selectedCategoryId.value;
                if (id == "all_items" || id == "low_stock") {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => controller.addItem(),
                    icon: const Icon(Icons.add_box_outlined, size: 18),
                    label: const Text("Add Item"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => controller.addCategory(),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text("Add Category"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.inventory_2_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Stocks",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Track and manage inventory levels",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool isFullWidth) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => Container(
                width: isFullWidth ? double.infinity : null,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(color: const Color(0xFFF1F0F7)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategoryId.value,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey),
                    onChanged: (v) => controller.onCategoryChanged(v),
                    items: [
                      const DropdownMenuItem(
                          value: "all_items",
                          child: Text("📋 All Stock Items",
                              style: TextStyle(fontWeight: FontWeight.w600))),
                      const DropdownMenuItem(
                          value: "low_stock",
                          child: Text("⚠️ Low Stock Items",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red))),
                      ...controller.categories.map((cat) => DropdownMenuItem(
                            value: cat.id.toString(),
                            child: Text(cat.name ?? ""),
                          )),
                    ],
                  ),
                ),
              )),
        ),
        Obx(() {
          final id = controller.selectedCategoryId.value;
          if (id == "all_items" || id == "low_stock") {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              onPressed: () => controller.deleteCategory(id),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 22),
              tooltip: "Delete Category",
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDesktopTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F0F7)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
            headingRowHeight: 60,
            columnSpacing: 24,
            columns: const [
              DataColumn(
                  label: Text("ITEM NAME",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text("CATEGORY",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text("STOCK",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text("STATUS",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text("ACTIONS",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5))),
            ],
            rows: controller.filteredStocks.map((stock) {
              final qty = double.tryParse(stock.quantity ?? "0") ?? 0;
              return DataRow(cells: [
                DataCell(Text(stock.name ?? "—",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14))),
                DataCell(Text(stock.categoryName ?? "—",
                    style: const TextStyle(color: Colors.grey))),
                DataCell(Text("${stock.quantity ?? "0"} ${stock.type ?? "—"}",
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(_buildStatusBadge(qty)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded,
                          size: 22, color: AppColors.primary),
                      onPressed: () {},
                      tooltip: "Edit",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 22, color: Colors.grey),
                      onPressed: () => controller.deleteItem(stock),
                      tooltip: "Delete",
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      itemCount: controller.filteredStocks.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final stock = controller.filteredStocks[index];
        final qty = double.tryParse(stock.quantity ?? "0") ?? 0;
        final alert = double.tryParse(stock.alert ?? "0") ?? 0;
        final isLow = alert > 0 && qty <= alert;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isLow
                    ? Colors.red.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
            border: Border.all(
              color: isLow ? Colors.red.withOpacity(0.2) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isLow ? Colors.red : AppColors.primary)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          color: isLow ? Colors.red : AppColors.primary,
                          size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stock.name ?? "—",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  letterSpacing: -0.4)),
                          const SizedBox(height: 2),
                          Text(stock.categoryName ?? "General",
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text(
                            "${stock.quantity ?? "0"} ${stock.type ?? ""}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isLow ? Colors.red : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Row(
                          children: [
                            Icon(Icons.trending_down_rounded,
                                color: Colors.red, size: 14),
                            SizedBox(width: 4),
                            Text("LOW",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: Icon(Icons.delete_sweep_outlined,
                          color: Colors.grey[300], size: 22),
                      onPressed: () => controller.deleteItem(stock),
                    ),
                  ],
                ),
              ),
              _buildProgressBar(qty, alert),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "STOCK LEVEL",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "Min: ${stock.alert ?? "0"} ${stock.type ?? ""}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isLow ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                        child:
                            _buildInfoBox("RATE", "₹${stock.ntePrice ?? "0"}")),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildInfoBox(
                            "TOTAL", "₹${stock.totalPrice ?? "0"}",
                            isPrimary: true)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                          Icons.add_rounded,
                          "Increase",
                          const Color(0xFFF4EFFC),
                          AppColors.primary,
                          () => controller.increaseStock(stock)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                          Icons.remove_rounded,
                          "Decrease",
                          const Color(0xFFFFF2F2),
                          Colors.red,
                          () => controller.decreaseStock(stock)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(double qty, double alert) {
    // Exact website formula: qty / (alert * 4)
    double progress = alert > 0 ? (qty / (alert * 4)) : 1.0;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.05 && qty > 0) progress = 0.05;

    // Exact website color logic:
    Color color;
    if (qty <= alert) {
      color = Colors.red;
    } else if (progress > 0.6) {
      color = const Color(0xFF2ECC71); // Emerald Green
    } else {
      color = Colors.orange; // Amber Orange
    }

    return Container(
      height: 5, // Thinner as per close-up
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0F7),
        borderRadius: BorderRadius.circular(10), // Pill shaped
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 1),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F0F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              )),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isPrimary
                    ? const Color(0xFF2ECC71)
                    : Colors.black, // Green for Total Value
                fontSize: 17,
              )),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor,
      Color textColor, VoidCallback onTap) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  )),
            ],
          ),
        ),
      ),
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
      color = const Color(0xFF2ECC71);
      label = "In Stock";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined,
                size: 80, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text(
            "No Items in Stock",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.grey[400],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add items to start tracking your inventory",
            style: TextStyle(color: Colors.grey[400], fontSize: 15),
          ),
        ],
      ),
    );
  }
}
