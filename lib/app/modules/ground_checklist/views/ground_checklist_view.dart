import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/ground_checklist_model.dart';
import '../controllers/ground_checklist_controller.dart';
import 'ground_checklist_dialogs.dart';
import '../../layout/views/layout_view.dart';

class GroundChecklistView extends GetView<GroundChecklistController> {
  const GroundChecklistView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 11,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: const Color(0xFFF8F9FD),
          child: Padding(
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
                      return _buildEmptyState(context);
                    }

                    return isMobile
                        ? _buildMobileContent(context)
                        : _buildDesktopContent(context);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 16,
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF4EFFC), Color(0xFFECE2FA)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.rule_folder_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ground Checklist',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 24 : 30,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${controller.categories.length} categories • ${controller.totalItems} items',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => GroundChecklistDialogs.showCategoryDialog(
                context,
                controller,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => GroundChecklistDialogs.showItemDialog(
                context,
                controller,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Item'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360,
          child: _buildCategoryPanel(context),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildItemPanel(context),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return ListView(
      children: [
        _buildCategoryPanel(context),
        const SizedBox(height: 16),
        _buildItemPanel(context),
      ],
    );
  }

  Widget _buildCategoryPanel(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATEGORIES LIST',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            controller.categories.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildCategoryCard(
                context,
                controller.categories[index],
                index + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    GroundChecklistCategory category,
    int index,
  ) {
    return Obx(() {
      final isActive = controller.activeCategory?.id == category.id;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFE5E7EB),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => controller.selectCategory(category.id),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: GoogleFonts.inter(
                        color:
                            isActive ? Colors.white : const Color(0xFF6B7280),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isActive
                                ? AppColors.primary
                                : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${category.groundItems.length} item${category.groundItems.length == 1 ? '' : 's'}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        GroundChecklistDialogs.showCategoryDialog(
                          context,
                          controller,
                          category: category,
                        );
                      } else if (value == 'delete') {
                        controller.deleteCategory(category);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Category'),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Category'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildItemPanel(BuildContext context) {
    return Obx(() {
      final category = controller.activeCategory;
      final items = controller.filteredItems;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.folder_open_rounded,
                                color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                category?.name ?? 'Select Category',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${category?.groundItems.length ?? 0} total items in this category',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: TextField(
                onChanged: controller.onSearchChanged,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "Search products...",
                  hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF9CA3AF), fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 18, color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: items.isEmpty
                  ? _buildItemEmptyState(context)
                  : Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: items
                          .map((item) => _buildItemCard(context, item))
                          .toList(),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildItemCard(BuildContext context, GroundChecklistItem item) {
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCCB5F2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F1FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sell_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unit: ${item.unit?.isNotEmpty == true ? item.unit : '-'}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                GroundChecklistDialogs.showItemDialog(
                  context,
                  controller,
                  item: item,
                );
              } else if (value == 'delete') {
                controller.deleteItem(item);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit Item'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete Item'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemEmptyState(BuildContext context) {
    final hasQuery = controller.searchQuery.value.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 54, color: Colors.grey[300]),
          const SizedBox(height: 14),
          Text(
            hasQuery
                ? 'No items match your search'
                : 'No items in this category',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist_rtl_rounded,
                size: 68, color: Colors.grey[300]),
            const SizedBox(height: 18),
            Text(
              'No Checklists Available',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Checklists will appear here once configured',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => GroundChecklistDialogs.showCategoryDialog(
                context,
                controller,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
