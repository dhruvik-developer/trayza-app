import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading.dart';
import '../../../data/models/ground_checklist_model.dart';
import '../controllers/ground_checklist_controller.dart';
import 'ground_checklist_dialogs.dart';
import '../../layout/views/layout_view.dart';

class GroundChecklistView extends GetView<GroundChecklistController> {
  const GroundChecklistView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 8,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: const Color(0xFFF8F9FD),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isMobile),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const LoaderWebView();
                    }

                    if (controller.categories.isEmpty) {
                      return _buildEmptyState(context);
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.playlist_add_check_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ground Checklist',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 20 : 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${controller.categories.length} categories • ${controller.totalItems} items',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // PopupMenuButton<String>(
        //   tooltip: 'Checklist actions',
        //   offset: const Offset(0, 42),
        //   onSelected: (value) {
        //     if (value == 'add_category') {
        //       GroundChecklistDialogs.showCategoryDialog(context, controller);
        //     } else if (value == 'add_item') {
        //       GroundChecklistDialogs.showItemDialog(context, controller);
        //     }
        //   },
        //   itemBuilder: (_) => const [
        //     PopupMenuItem<String>(
        //       value: 'add_category',
        //       child: Text('Add Category'),
        //     ),
        //     PopupMenuItem<String>(
        //       value: 'add_item',
        //       child: Text('Add Item'),
        //     ),
        //   ],
        //   child: Container(
        //     width: 42,
        //     height: 42,
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(14),
        //       border: Border.all(color: const Color(0xFFEAEAF2)),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withValues(alpha: 0.04),
        //           blurRadius: 10,
        //           offset: const Offset(0, 4),
        //         ),
        //       ],
        //     ),
        //     child: const Icon(Icons.add_rounded,
        //         color: AppColors.primary, size: 22),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          child: _buildDesktopCategoryList(context),
        ),
        const SizedBox(width: 28),
        Expanded(child: _buildDetailPanel(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 90,
          child: Obx(
            () => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) => _buildCategoryCard(
                context,
                controller.categories[index],
                index + 1,
                compact: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailPanel(context),
      ],
    );
  }

  Widget _buildDesktopCategoryList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'GROUND CATEGORIES',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9CA3AF),
              letterSpacing: 1.4,
            ),
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView.separated(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: controller.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildCategoryCard(
                context,
                controller.categories[index],
                index + 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    GroundChecklistCategory category,
    int position, {
    bool compact = false,
  }) {
    return Obx(() {
      final isActive = controller.activeCategory?.id == category.id;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 170,
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
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.selectCategory(category.id),
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.20)
                              : const Color(0xFFF3F4F8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$position',
                          style: GoogleFonts.inter(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
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
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: compact ? 13 : 15,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.layers_outlined,
                                  size: 12,
                                  color: isActive
                                      ? Colors.white.withValues(alpha: 0.82)
                                      : const Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${category.groundItems.length} items',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isActive
                                        ? Colors.white.withValues(alpha: 0.82)
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
            // Positioned(
            //   top: 6,
            //   right: 4,
            //   child: PopupMenuButton<String>(
            //     splashRadius: 18,
            //     onSelected: (value) {
            //       if (value == 'edit') {
            //         GroundChecklistDialogs.showCategoryDialog(
            //           context,
            //           controller,
            //           category: category,
            //         );
            //       } else if (value == 'delete') {
            //         controller.deleteCategory(category);
            //       }
            //     },
            //     itemBuilder: (_) => const [
            //       PopupMenuItem<String>(
            //         value: 'edit',
            //         child: Text('Edit Category'),
            //       ),
            //       PopupMenuItem<String>(
            //         value: 'delete',
            //         child: Text('Delete Category'),
            //       ),
            //     ],
            //     icon: Icon(
            //       Icons.more_vert_rounded,
            //       color: isActive
            //           ? Colors.white.withValues(alpha: 0.90)
            //           : const Color(0xFF9CA3AF),
            //       size: 18,
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailPanel(BuildContext context) {
    final isMobile = context.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border:
            Border.all(color: const Color(0xFFE8E0F3).withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailHeaderInfo(),
                      const SizedBox(height: 16),
                      _buildSearchField(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildDetailHeaderInfo()),
                      const SizedBox(width: 20),
                      SizedBox(width: 300, child: _buildSearchField()),
                    ],
                  ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Obx(() {
            final items = controller.filteredItems;

            if (items.isEmpty) {
              return _buildItemEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(18),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildItemCard(context, items[index]),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailHeaderInfo() {
    return Obx(() {
      final selected = controller.activeCategory;

      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected?.name ?? 'Select Category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F2937),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${selected?.groundItems.length ?? 0} items in this category',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSearchField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F1F5)),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF374151),
        ),
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFFB0B7C3),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFB0B7C3),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, GroundChecklistItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0F1F5)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {},
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.build_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          if ((item.unit ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.unit!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFB0B7C3),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Positioned(
          //   top: 6,
          //   right: 4,
          //   child: PopupMenuButton<String>(
          //     splashRadius: 18,
          //     onSelected: (value) {
          //       if (value == 'edit') {
          //         GroundChecklistDialogs.showItemDialog(
          //           context,
          //           controller,
          //           item: item,
          //         );
          //       } else if (value == 'delete') {
          //         controller.deleteItem(item);
          //       }
          //     },
          //     itemBuilder: (_) => const [
          //       PopupMenuItem<String>(
          //         value: 'edit',
          //         child: Text('Edit Item'),
          //       ),
          //       PopupMenuItem<String>(
          //         value: 'delete',
          //         child: Text('Delete Item'),
          //       ),
          //     ],
          //     icon: const Icon(
          //       Icons.more_vert_rounded,
          //       color: Color(0xFFB0B7C3),
          //       size: 18,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildItemEmptyState() {
    final hasQuery = controller.searchQuery.value.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            hasQuery
                ? 'No items match your search'
                : 'No items in this category',
            textAlign: TextAlign.center,
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
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.playlist_add_check_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Checklists Available',
              style: GoogleFonts.inter(
                fontSize: 22,
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => GroundChecklistDialogs.showCategoryDialog(
                      context, controller),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Category'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => GroundChecklistDialogs.showItemDialog(
                      context, controller),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Item'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
