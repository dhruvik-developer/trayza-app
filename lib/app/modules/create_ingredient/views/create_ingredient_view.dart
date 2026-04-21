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
                      ? _buildMobileLayout(context)
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
                    Text(
                      "Create Ingredient Items",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${controller.categories.length} categories • ${controller.categories.fold(0, (sum, c) => sum + c.items.length)} items",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
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
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                child: Text(
                  "INGREDIENT CATEGORIES",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.categories.length,
                  padding: const EdgeInsets.only(bottom: 24),
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
        const SizedBox(width: 32),
        // Right Column: Detail List
        Expanded(child: _buildDetailPanel(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _buildCategoryMasterCard(
                controller.categories[index], index + 1,
                compact: true),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(child: _buildDetailPanel(context)),
      ],
    );
  }

  Widget _buildCategoryMasterCard(dynamic cat, int position,
      {bool compact = false}) {
    return Obx(() {
      final isActive = controller.selectedCategoryId.value == cat.id;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: compact ? 190 : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          color: isActive ? Colors.white : const Color(0xFFF9FAFB),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.03),
              blurRadius: isActive ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => controller.selectCategory(cat.id),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [AppColors.primary, Color(0xFFA78BFA)])
                        : LinearGradient(
                            colors: [Colors.grey[200]!, Colors.grey[100]!]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$position",
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.layers_outlined,
                              size: 12,
                              color: isActive
                                  ? AppColors.primary.withOpacity(0.6)
                                  : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${cat.items.length} items",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? AppColors.primary.withOpacity(0.7)
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDetailPanel(BuildContext context) {
    bool isMobile = context.width < 600;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE8E0F3).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Detail Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailHeaderInfo(),
                      const SizedBox(height: 16),
                      _buildSearchField(width: double.infinity),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildDetailHeaderInfo()),
                      const SizedBox(width: 24),
                      _buildSearchField(width: 280),
                    ],
                  ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          // Items Grid
          Expanded(
            child: Obx(() {
              final items = controller.filteredItems;
              if (items.isEmpty) return _buildDetailEmptyState();

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 80,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
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

  Widget _buildDetailHeaderInfo() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.grid_view_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.selectedCategory?.name ?? "Select Category",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Text(
                "${controller.filteredItems.length} items in this category",
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }

  Widget _buildSearchField({required double width}) {
    return Container(
      width: width,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        onChanged: controller.onSearchChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Search ingredients...",
          hintStyle:
              TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
          prefixIcon:
              const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDetailItemCard(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant_menu_outlined,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
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
