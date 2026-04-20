import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/item_controller.dart';

class ItemView extends GetView<ItemController> {
  const ItemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 600;
    return LayoutView(
      activeIndex: 4,
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
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
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
                  if (controller.categories.isEmpty) {
                    return _buildEmptyState();
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryAccordion(context, controller.categories[index]);
                      },
                    ),
                  );
                }),
                _buildFooterActions(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return isMobile 
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildIconBox(18),
                const SizedBox(width: 12),
                const Text("Items", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            _buildSelectionText(),
            const SizedBox(height: 12),
            _buildAddItemBtn(true),
          ],
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildIconBox(22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Items", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    _buildSelectionText(),
                  ],
                ),
              ],
            ),
            _buildAddItemBtn(false),
          ],
        );
  }

  Widget _buildIconBox(double size) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
      child: Icon(Icons.list_alt_rounded, color: AppColors.primary, size: size),
    );
  }

  Widget _buildSelectionText() {
    return Obx(() {
      final total = controller.getGrandTotalSelected();
      return Text(
        total > 0 ? "$total items selected" : "Select items for your order",
        style: TextStyle(fontSize: 13, color: total > 0 ? AppColors.primary : AppColors.textSecondary, fontWeight: total > 0 ? FontWeight.bold : FontWeight.normal),
      );
    });
  }

  Widget _buildAddItemBtn(bool fullWidth) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 16),
        label: const Text("Add Item"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryAccordion(BuildContext context, category) {
    bool isExpanded = controller.expandedCategoryIds.contains(category.id);
    int selectedCount = controller.getSelectedCount(category.id);
    bool isMobile = context.width < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.toggleCategory(category.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF8F5FC), Colors.white], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.vertical(top: const Radius.circular(12), bottom: Radius.circular(isExpanded ? 0 : 12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text("${category.positions ?? ""}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(category.name ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                  if (selectedCount > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(20)),
                      child: Text("$selectedCount", style: const TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isMobile ? 200 : 250,
                  mainAxisExtent: 48,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: category.items?.length ?? 0,
                itemBuilder: (context, iIndex) => _buildItemChip(category.id, category.items![iIndex]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemChip(int categoryId, item) {
    bool isSelected = controller.isItemSelected(categoryId, item.id);
    return InkWell(
      onTap: () => controller.toggleItemSelection(categoryId, item.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4EFFC) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 16, color: isSelected ? AppColors.primary : Colors.grey[400]),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name ?? "", style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primary : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text("Back", style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isMobile ? "Submit" : "Submit Selection", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No Items Available", style: TextStyle(color: Colors.grey)));
  }
}
