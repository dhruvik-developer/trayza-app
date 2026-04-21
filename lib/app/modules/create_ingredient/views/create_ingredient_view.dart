import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/create_ingredient_controller.dart';
import 'ingredient_dialogs.dart';

class CreateIngredientView extends GetView<CreateIngredientController> {
  const CreateIngredientView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 8,
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.categories.isEmpty) {
                    return _buildEmptyState();
                  }

                  return isMobile
                      ? _buildMobileLayout()
                      : _buildDesktopLayout(context);
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
                    color: const Color(0xFFF4EFFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.note_add_outlined,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create Ingredient Items",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    Obx(() => Text(
                          "${controller.categories.length} categories • ${controller.categories.fold(0, (sum, c) => sum + c.items.length)} items",
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                        )),
                  ],
                ),
              ],
            ),
            if (!isMobile) _buildActionButtons(context),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildActionButton("+ Add Category", true,
            () => IngredientDialogs.showAddCategory(context, controller)),
        _buildActionButton("+ Add Item", false,
            () => IngredientDialogs.showAddItem(context, controller)),
      ],
    );
  }

  Widget _buildActionButton(String label, bool isPrimary, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColors.primary,
        side: isPrimary ? null : const BorderSide(color: AppColors.primary),
        elevation: isPrimary ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Master List
        SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("INGREDIENT CATEGORIES",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    return _buildCategoryMasterCard(cat, index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Column: Detail List
        Expanded(child: _buildDetailPanel()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildCategoryMasterCard(
                controller.categories[index], index + 1,
                compact: true),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildDetailPanel()),
      ],
    );
  }

  Widget _buildCategoryMasterCard(dynamic cat, int position,
      {bool compact = false}) {
    return Obx(() {
      final isActive = controller.selectedCategoryId.value == cat.id;

      return Container(
        width: compact ? 180 : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isActive ? AppColors.primary : const Color(0xFFE8E0F3)),
          color: isActive ? const Color(0xFFF4EFFC) : Colors.white,
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: InkWell(
          onTap: () => controller.selectCategory(cat.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(
                    "$position",
                    style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.name,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis),
                      Text("${cat.items.length} items",
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDetailPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E0F3)),
      ),
      child: Column(
        children: [
          // Detail Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.grid_view,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                  controller.selectedCategory?.name ??
                                      "Select Category",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                              "${controller.filteredItems.length} items in this category",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      )),
                ),
                const SizedBox(width: 16),
                _buildSearchField(),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items Grid
          Expanded(
            child: Obx(() {
              final items = controller.filteredItems;
              if (items.isEmpty) return _buildDetailEmptyState();

              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _buildDetailItemCard(items[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E0F3))),
      child: TextField(
        onChanged: controller.onSearchChanged,
        decoration: const InputDecoration(
            hintText: "Search ingredients...",
            prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      ),
    );
  }

  Widget _buildDetailItemCard(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          color: Colors.white),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_basket_outlined,
                size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[200]),
          const SizedBox(height: 12),
          const Text("No Ingredients Found",
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No Recipes Found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          TextButton(
              onPressed: () => controller.fetchCategories(),
              child: const Text("Tap to Refresh")),
        ],
      ),
    );
  }
}
