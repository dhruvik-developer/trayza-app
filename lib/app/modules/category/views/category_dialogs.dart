import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/category_controller.dart';

class CategoryDialogs {
  static void showAddCategory(BuildContext context, CategoryController controller) {
    final nameController = TextEditingController();

    Get.dialog(
      _DialogWrapper(
        title: "Create Category",
        subtitle: "Add a new category to organize items",
        icon: Icons.folder_outlined,
        onSave: () => controller.createCategory(nameController.text),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Category Name *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Please Enter Category Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showAddItem(BuildContext context, CategoryController controller) {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final rateController = TextEditingController();
    final selectedCatId = (controller.selectedCategoryId.value ?? (controller.categories.isNotEmpty ? controller.categories.first.id : 0)).obs;

    Get.dialog(
      _DialogWrapper(
        title: "Create Item",
        subtitle: "Add a new item with pricing details",
        icon: Icons.tag_outlined,
        onSave: () => controller.createItem(
          nameController.text,
          selectedCatId.value,
          double.tryParse(costController.text) ?? 0.0,
          double.tryParse(rateController.text) ?? 0.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Item Name *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Please Enter Item Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Category *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8E0F3)), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: selectedCatId.value == 0 ? null : selectedCatId.value,
                      items: controller.categories
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) { if (v != null) selectedCatId.value = v; },
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.currency_rupee, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                const Text("Pricing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPriceInput("Base Cost (₹)", costController, "The raw cost of this item"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPriceInput("Selection Rate (₹)", rateController, "The rate when item is selected"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPriceInput(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "e.g. 100",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(hint, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  static void showAddIngredient(BuildContext context, CategoryController controller) {
    // Replicating the "Add Recipe Ingredient" Modal
    final personCountController = TextEditingController(text: "100");
    final selectedItemId = 0.obs;

    Get.dialog(
      _DialogWrapper(
        title: "Add Recipe Ingredient",
        subtitle: "Create a new recipe with ingredients",
        icon: Icons.book_outlined,
        onSave: () {
          controller.createRecipe({
            "item": selectedItemId.value,
            "person_count": int.tryParse(personCountController.text) ?? 100,
            "ingredients": [], // Would normally map dynamic rows here
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               children: [
                 const Icon(Icons.people_outline, color: Colors.green, size: 16),
                 const SizedBox(width: 8),
                 Text("RECIPE FOR PERSON COUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.0)),
               ],
             ),
             const SizedBox(height: 8),
             TextField(
               controller: personCountController,
               keyboardType: TextInputType.number,
               decoration: InputDecoration(
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               ),
             ),
             const SizedBox(height: 20),
             const Text("Select Item *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
             const SizedBox(height: 8),
             Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8E0F3)), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: null,
                    hint: const Text("Select an item"),
                    items: [], // Would normally be populated with all items
                    onChanged: (v) {},
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Ingredients will show up here after selecting an item.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _DialogWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final VoidCallback onSave;

  const _DialogWrapper({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shadowColor: Colors.black26,
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: context.width < 600 ? context.width - 40 : 540,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF4EFFC), Colors.white],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                          child: Icon(icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                            Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: child,
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel", style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Save ${title.split(' ').last}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
