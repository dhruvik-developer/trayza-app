import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isMobile),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.categories.isEmpty) {
                    return _buildEmptyState();
                  }

                  return isMobile
                      ? _buildMobileLayout(context)
                      : SizedBox(
                          height: context.height - 200,
                          child: _buildDesktopLayout(context),
                        );
                }),
              ],
            ),
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
                  child: Icon(Icons.note_add_outlined,
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
                            style: TextStyle(
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
            // if (!isMobile) _buildActionButtons(context),
          ],
        ),
        // if (isMobile) ...[
        //   const SizedBox(height: 16),
        //   _buildActionButtons(context),
        // ],
      ],
    );
  }

  // Widget _buildActionButtons(BuildContext context) {
  //   return Wrap(
  //     spacing: 12,
  //     runSpacing: 8,
  //     children: [
  //       _buildActionButton("+ Add Category", true,
  //           () => IngredientDialogs.showAddCategory(context, controller)),
  //       _buildActionButton("+ Add Item", false,
  //           () => IngredientDialogs.showAddItem(context, controller)),
  //     ],
  //   );
  // }

  // Widget _buildActionButton(String label, bool isPrimary, VoidCallback onTap) {
  //   return ElevatedButton(
  //     onPressed: onTap,
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: isPrimary ? AppColors.primary : Colors.white,
  //       foregroundColor: isPrimary ? Colors.white : AppColors.primary,
  //       side: isPrimary ? null : const BorderSide(color: AppColors.primary),
  //       elevation: isPrimary ? 2 : 0,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     ),
  //     child: Text(label,
  //         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  //   );
  // }

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
                    return _buildCategoryMasterCard(context, cat, index + 1);
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 90,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _buildCategoryMasterCard(
                context, controller.categories[index], index + 1,
                compact: true),
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailPanel(context),
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
        width: 170,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
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
            onTap: () => controller.selectCategory(cat.id),
            // onLongPress: () => IngredientDialogs.showDeleteConfirmation(
            //   context: context,
            //   title: "Delete Category",
            //   message:
            //       "Are you sure you want to delete '${cat.name}'? This will also delete all items in this category.",
            //   onConfirm: () => controller.deleteCategory(cat.id),
            // ),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$position",
                      style: GoogleFonts.inter(
                        color:
                            isActive ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
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
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.layers_outlined,
                              size: 12,
                              color: isActive
                                  ? Colors.white.withOpacity(0.8)
                                  : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${cat.items.length} items",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? Colors.white.withOpacity(0.8)
                                    : const Color(0xFF9CA3AF),
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
            padding: const EdgeInsets.all(16),
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
          Obx(() {
            final items = controller.filteredItems;

            if (items.isEmpty) return _buildDetailEmptyState();

            return ListView.builder(
              padding: const EdgeInsets.all(18),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDetailItemCard(context, items[index]),
                );
              },
            );
          }),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.grid_view_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedCategory?.name ?? "Select Category",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${controller.filteredItems.length} items in this category",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildSearchField({required double width}) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        onChanged: controller.onSearchChanged,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Search ingredients...",
          hintStyle:
              GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 18, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildDetailItemCard(BuildContext context, dynamic item) {
    return Container(
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
      child: InkWell(
        // onLongPress: () => IngredientDialogs.showDeleteConfirmation(
        //   context: context,
        //   title: "Delete Item",
        //   message: "Are you sure you want to delete '${item.name}'?",
        //   onConfirm: () => controller.deleteItem(item.id),
        // ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.restaurant_menu_outlined,
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
        ),
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
