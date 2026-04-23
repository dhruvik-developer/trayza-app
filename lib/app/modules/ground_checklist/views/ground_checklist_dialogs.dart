import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/ground_checklist_model.dart';
import '../controllers/ground_checklist_controller.dart';

class GroundChecklistDialogs {
  static void showCategoryDialog(
    BuildContext context,
    GroundChecklistController controller, {
    GroundChecklistCategory? category,
  }) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController =
        TextEditingController(text: category?.description ?? '');
    final isActive = (category?.isActive ?? true).obs;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogHeader(
                  title: category == null
                      ? 'Add Ground Category'
                      : 'Edit Ground Category',
                  subtitle: 'Manage checklist groups exactly like the website',
                  icon: Icons.folder_outlined,
                ),
                const SizedBox(height: 20),
                const _FieldLabel('Category Name'),
                const SizedBox(height: 8),
                _DialogInput(
                  controller: nameController,
                  hintText: 'e.g. Safety Items',
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Description'),
                const SizedBox(height: 8),
                _DialogInput(
                  controller: descriptionController,
                  hintText: 'Optional description',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => SwitchListTile(
                    value: isActive.value,
                    onChanged: (value) => isActive.value = value,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                  ),
                ),
                const SizedBox(height: 20),
                _DialogActions(
                  onSave: () => controller.saveCategory(
                    id: category?.id,
                    name: nameController.text,
                    description: descriptionController.text,
                    isActive: isActive.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showItemDialog(
    BuildContext context,
    GroundChecklistController controller, {
    GroundChecklistItem? item,
  }) {
    final categories = controller.activeCategoriesOnly;
    final defaultCategoryId = item?.categoryId ??
        controller.activeCategory?.id ??
        (categories.isNotEmpty ? categories.first.id : null);

    if (defaultCategoryId == null) {
      Get.snackbar(
        'Category Required',
        'Please create a category first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final nameController = TextEditingController(text: item?.name ?? '');
    final unitController = TextEditingController(text: item?.unit ?? '');
    final descriptionController =
        TextEditingController(text: item?.description ?? '');
    final selectedCategoryId = defaultCategoryId.obs;
    final isActive = (item?.isActive ?? true).obs;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogHeader(
                  title: item == null ? 'Add Ground Item' : 'Edit Ground Item',
                  subtitle: 'Keep mobile checklist items aligned with web',
                  icon: Icons.sell_outlined,
                ),
                const SizedBox(height: 20),
                const _FieldLabel('Item Name'),
                const SizedBox(height: 8),
                _DialogInput(
                  controller: nameController,
                  hintText: 'e.g. Gas Cylinder',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Category'),
                          const SizedBox(height: 8),
                          Obx(
                            () => _DialogDropdown<int>(
                              value: selectedCategoryId.value,
                              items: categories
                                  .map(
                                    (category) => DropdownMenuItem<int>(
                                      value: category.id,
                                      child: Text(category.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  selectedCategoryId.value = value;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Unit'),
                          const SizedBox(height: 8),
                          _DialogInput(
                            controller: unitController,
                            hintText: 'e.g. Nos, Kg, Set',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Description'),
                const SizedBox(height: 8),
                _DialogInput(
                  controller: descriptionController,
                  hintText: 'Optional description',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => SwitchListTile(
                    value: isActive.value,
                    onChanged: (value) => isActive.value = value,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                  ),
                ),
                const SizedBox(height: 20),
                _DialogActions(
                  onSave: () => controller.saveItem(
                    id: item?.id,
                    name: nameController.text,
                    categoryId: selectedCategoryId.value,
                    unit: unitController.text,
                    description: descriptionController.text,
                    isActive: isActive.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.back<void>(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
      ),
    );
  }
}

class _DialogInput extends StatelessWidget {
  const _DialogInput({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _DialogDropdown<T> extends StatelessWidget {
  const _DialogDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
