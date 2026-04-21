import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/category_controller.dart';
import 'category_dialogs.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 1,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
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
                    return _buildLoadingState(isMobile);
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF4EFFC), Color(0xFFE8E0F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.folder_copy_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Categories",
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Obx(() => Text(
                          "${controller.categories.length} organized categories",
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500),
                        )),
                  ],
                ),
              ],
            ),
            if (!isMobile) _buildActionButtons(context),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 20),
          _buildActionButtons(context),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        _buildActionButton("+ Add Category", true,
            () => CategoryDialogs.showAddCategory(context, controller)),
        _buildActionButton("+ Add Ingredient", false,
            () => CategoryDialogs.showAddIngredient(context, controller)),
        _buildActionButton("+ Add Item", false,
            () => CategoryDialogs.showAddItem(context, controller)),
      ],
    );
  }

  Widget _buildActionButton(String label, bool isPrimary, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppColors.primary,
          side: isPrimary
              ? null
              : const BorderSide(color: AppColors.primary, width: 1.5),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
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
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Text("CATEGORIES LIST",
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF9CA3AF),
                        letterSpacing: 1.5)),
              ),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final cat = controller.categories[index];
                    return _buildCategoryMasterCard(context, cat, index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 28),
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
            padding: const EdgeInsets.only(bottom: 8),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => _buildCategoryMasterCard(
                context, controller.categories[index], index + 1,
                compact: true),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(child: _buildDetailPanel(context)),
      ],
    );
  }

  Widget _buildCategoryMasterCard(
      BuildContext context, dynamic cat, int position,
      {bool compact = false}) {
    return Obx(() {
      final isActive = controller.selectedCategoryId.value == cat.id;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: compact ? 200 : null,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Colors.white, Colors.white],
                ),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectCategory(cat.id),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$position",
                      style: GoogleFonts.inter(
                        color:
                            isActive ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${cat.items.length} product${cat.items.length == 1 ? '' : 's'}",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!compact && isActive) ...[
                    _buildCompactActionIcon(
                      Icons.edit_note_rounded,
                      () => CategoryDialogs.showEditCategory(
                          context, controller, cat.id, cat.name),
                    ),
                    const SizedBox(width: 8),
                    _buildCompactActionIcon(
                      Icons.swap_vert_rounded,
                      () => CategoryDialogs.showSwapPosition(
                          context, controller, cat.id, cat.name),
                    ),
                    const SizedBox(width: 8),
                    _buildCompactActionIcon(
                      Icons.delete_sweep_rounded,
                      () => CategoryDialogs.showDeleteConfirmation(
                        title: "Delete Category",
                        message:
                            "Deleting '${cat.name}' will remove all products under it. This cannot be undone.",
                        onConfirm: () => controller.deleteCategory(cat.id),
                      ),
                      isDanger: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCompactActionIcon(IconData icon, VoidCallback onTap,
      {bool isDanger = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.white),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildDetailPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          // Detail Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_mosaic_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                controller.selectedCategory?.name ??
                                    "Select Category",
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${controller.filteredItems.length} products available in this section",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )),
                ),
                const SizedBox(width: 16),
                _buildSearchField(),
              ],
            ),
          ),
          // Scrollable Items Grid
          Expanded(
            child: Obx(() {
              final items = controller.filteredItems;
              if (items.isEmpty) return _buildDetailEmptyState();

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: items.length,
                itemBuilder: (_, index) =>
                    _buildDetailItemCard(context, items[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 280,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        onChanged: controller.onSearchChanged,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Search products...",
          hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
      ),
    );
  }

  Widget _buildDetailItemCard(BuildContext context, dynamic item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
          color: item.hasRecipe
              ? const Color(0xFFF3F4F6)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CategoryDialogs.showViewIngredients(context, controller, item),
          onLongPress: () => CategoryDialogs.showDeleteConfirmation(
            title: "Remove Product",
            message: "Permanently remove '${item.name}' from the menu?",
            onConfirm: () => controller.deleteCategoryItem(item.id),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.hasRecipe
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.hasRecipe
                        ? Icons.restaurant_rounded
                        : Icons.label_rounded,
                    size: 18,
                    color: item.hasRecipe ? AppColors.primary : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: item.hasRecipe
                              ? const Color(0xFF1F2937)
                              : Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!item.hasRecipe) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              "₹${item.baseCost ?? '0'}",
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green),
                            ),
                            const Text(" • ",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                            Text(
                              "₹${item.selectionRate ?? '0'}",
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => CategoryDialogs.showEditItemCosts(
                      context, controller, item),
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Color(0xFF9CA3AF)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  hoverColor: AppColors.primary.withOpacity(0.05),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => CategoryDialogs.showDeleteConfirmation(
                    title: "Remove Product",
                    message: "Are you sure you want to delete '${item.name}'?",
                    onConfirm: () => controller.deleteCategoryItem(item.id),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: Color(0xFF9CA3AF)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  hoverColor: Colors.red.withOpacity(0.05),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.category_rounded,
                size: 64, color: const Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 20),
          Text(
            "Ready to Add Products?",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This category is currently empty.\nStart by adding your first product.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.folder_off_rounded,
                size: 80, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 28),
          Text(
            "No Categories Found",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Get started by creating your first category.",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile)
          SizedBox(
            width: 320,
            child: Column(
              children: List.generate(
                  6,
                  (index) => Container(
                        height: 72,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )),
            ),
          ),
        if (!isMobile) const SizedBox(width: 28),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
