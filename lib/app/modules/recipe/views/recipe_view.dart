import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/recipe_controller.dart';

class RecipeView extends GetView<RecipeController> {
  const RecipeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutView(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
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
                _buildHeader(),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.isEditing.value || controller.isAdding.value) {
                    return Expanded(child: _buildRecipeBuilder());
                  }
                  return Expanded(child: _buildRecipeDisplay());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${controller.itemName} Recipe", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Obx(() => Text("Ingredients for ${controller.personCount} persons", style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
              ],
            ),
          ],
        ),
        Obx(() {
          if (controller.isEditing.value || controller.isAdding.value) {
            return const SizedBox();
          }
          return ElevatedButton.icon(
            onPressed: controller.recipeEntries.isEmpty ? controller.startAdd : controller.startEdit,
            icon: Icon(controller.recipeEntries.isEmpty ? Icons.add : Icons.edit_note_rounded),
            label: Text(controller.recipeEntries.isEmpty ? "Create Recipe" : "Edit Recipe"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecipeDisplay() {
    if (controller.recipeEntries.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      itemCount: controller.recipeEntries.length,
      itemBuilder: (context, index) {
        final entry = controller.recipeEntries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E0F3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(entry.ingredient?.name ?? "Unknown Ingredient", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Text("${entry.quantity} ${entry.unit}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecipeBuilder() {
    return Column(
      children: [
        Expanded(
          child: Obx(() => ListView.builder(
            itemCount: controller.builderEntries.length,
            itemBuilder: (context, index) => _buildBuilderRow(index),
          )),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: controller.cancelAction, child: const Text("Cancel")),
            ElevatedButton(onPressed: controller.saveRecipe, child: const Text("Save Recipe")),
          ],
        ),
      ],
    );
  }

  Widget _buildBuilderRow(int index) {
    final row = controller.builderEntries[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: row.ingredientId,
              decoration: const InputDecoration(labelText: "Ingredient", border: OutlineInputBorder()),
              items: controller.ingredientOptions.map((opt) => DropdownMenuItem(value: opt.id, child: Text(opt.name ?? ""))).toList(),
              onChanged: (val) => row.ingredientId = val,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: row.quantity,
              decoration: const InputDecoration(labelText: "Qty", border: OutlineInputBorder()),
              onChanged: (val) => row.quantity = val,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: row.unit,
              decoration: const InputDecoration(labelText: "Unit", border: OutlineInputBorder()),
              onChanged: (val) => row.unit = val,
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => controller.removeBuilderRow(index)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text("No Recipe for this Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: controller.startAdd, child: const Text("Create Now")),
        ],
      ),
    );
  }
}
