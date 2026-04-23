import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/category_controller.dart';

class CategoryDialogs {
  static void showAddCategory(
      BuildContext context, CategoryController controller) {
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
            const Text("Category Name *",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Please Enter Category Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    final selectedCatId = (controller.selectedCategoryId.value ??
            (controller.categories.isNotEmpty
                ? controller.categories.first.id
                : 0))
        .obs;

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
            const Text("Item Name *",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Please Enter Item Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Category *",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8E0F3)),
                      borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value:
                          selectedCatId.value == 0 ? null : selectedCatId.value,
                      items: controller.categories
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) selectedCatId.value = v;
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.currency_rupee, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                const Text("Pricing",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPriceInput("Base Cost (₹)", costController,
                      "The raw cost of this item"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPriceInput("Selection Rate (₹)", rateController,
                      "The rate when item is selected"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPriceInput(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "e.g. 100",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(hint, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  static void showAddIngredient(
      BuildContext context, CategoryController controller,
      {int? itemId,
      int? initialPersonCount,
      List<Map<String, dynamic>>? existingIngredients}) {
    final personCountController =
        TextEditingController(text: (initialPersonCount ?? 100).toString());
    final RxInt selectedItemId = (itemId ?? 0).obs;

    // Initial rows: either existing ones or one empty row
    final List<Map<String, dynamic>> ingredientRows = [];
    if (existingIngredients != null && existingIngredients.isNotEmpty) {
      for (var ing in existingIngredients) {
        ingredientRows.add({
          "id": ing["id"],
          "ingredientId": ing["ingredientId"],
          "quantity": ing["quantity"]?.toString() ?? "",
          "unit": ing["unit"] ?? "g"
        });
      }
      // Add one empty row at the end
      ingredientRows.add({"ingredientId": null, "quantity": "", "unit": "g"});
    } else {
      ingredientRows.add({"ingredientId": null, "quantity": "", "unit": "g"});
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: context.width < 600 ? context.width - 40 : 800,
          constraints: BoxConstraints(maxHeight: context.height * 0.9),
          child: Obx(() {
            final currentItem = controller.categories
                .expand((c) => c.items)
                .firstWhereOrNull((i) => i.id == selectedItemId.value);
            final itemName = currentItem?.name ?? "New Recipe";

            return StatefulBuilder(builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildIngredientHeader(itemName, context),
                  const Divider(height: 1),

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Person Count
                          _buildSectionLabel(Icons.people_outline,
                              "RECIPE FOR PERSON COUNT", Colors.green),
                          const SizedBox(height: 8),
                          _buildPersonCountInput(personCountController),
                          const SizedBox(height: 24),

                          // Item Selection (only if itemId wasn't passed)
                          if (itemId == null) ...[
                            const Text("Select Item *",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF374151))),
                            const SizedBox(height: 8),
                            _buildItemDropdown(controller, selectedItemId),
                            const SizedBox(height: 32),
                          ],

                          // Ingredients Grid (only if item is selected)
                          if (selectedItemId.value != 0) ...[
                            _buildSectionLabel(Icons.inventory_2_outlined,
                                "INGREDIENTS", Colors.blue),
                            const SizedBox(height: 16),
                            _buildIngredientsTableHeader(),
                            const SizedBox(height: 8),
                            _buildIngredientsRows(
                                ingredientRows, controller, setDialogState),
                          ] else ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text(
                                    "Please select an item to add ingredients",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic)),
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  _buildIngredientFooter(ingredientRows, selectedItemId,
                      personCountController, controller),
                ],
              );
            });
          }),
        ),
      ),
    );
  }

  static Widget _buildIngredientHeader(String itemName, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppColors.primaryLight, Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, size: 20),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE5E7EB))),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add Recipe Ingredient",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937))),
                Text(itemName,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close, size: 20),
              style: IconButton.styleFrom(foregroundColor: Colors.grey)),
        ],
      ),
    );
  }

  static Widget _buildSectionLabel(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.0)),
      ],
    );
  }

  static Widget _buildPersonCountInput(TextEditingController controller) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "e.g. 100",
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  static Widget _buildItemDropdown(
      CategoryController controller, RxInt selectedItemId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE8E0F3)),
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: selectedItemId.value == 0 ? null : selectedItemId.value,
          hint: const Text("Select an item to add recipe",
              style: TextStyle(fontSize: 13)),
          items: controller.categories
              .expand((c) => c.items)
              .map((i) => DropdownMenuItem(
                  value: i.id,
                  child: Text(i.name, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (v) {
            if (v != null) selectedItemId.value = v;
          },
        ),
      ),
    );
  }

  static Widget _buildIngredientsTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text("NAME",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey))),
          SizedBox(width: 12),
          Expanded(
              flex: 2,
              child: Text("QUANTITY",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey))),
          SizedBox(width: 12),
          Expanded(
              flex: 1,
              child: Text("UNIT",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey))),
          SizedBox(width: 44),
        ],
      ),
    );
  }

  static Widget _buildIngredientsRows(List<Map<String, dynamic>> rows,
      CategoryController controller, StateSetter setState) {
    return Column(
      children: List.generate(rows.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              // Ingredient Dropdown
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8E0F3)),
                      borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: rows[index]["ingredientId"],
                      hint: const Text("Select ingredient",
                          style: TextStyle(fontSize: 13)),
                      items: controller.ingredients
                          .map((ing) => DropdownMenuItem(
                              value: ing['id'] as int,
                              child: Text(ing['name'] ?? 'Unknown',
                                  style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          rows[index]["ingredientId"] = v;
                          if (index == rows.length - 1) {
                            rows.add({
                              "ingredientId": null,
                              "quantity": "",
                              "unit": "g"
                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Quantity
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (v) => rows[index]["quantity"] = v,
                  decoration: InputDecoration(
                    hintText: "e.g. 100",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Unit
              Expanded(
                flex: 1,
                child: TextField(
                  onChanged: (v) => rows[index]["unit"] = v,
                  controller: TextEditingController(text: rows[index]["unit"]),
                  decoration: InputDecoration(
                    hintText: "g",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Delete
              SizedBox(
                width: 32,
                child: IconButton(
                  onPressed: index < rows.length - 1
                      ? () => setState(() => rows.removeAt(index))
                      : null,
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  static Widget _buildIngredientFooter(
      List<Map<String, dynamic>> rows,
      RxInt selectedItemId,
      TextEditingController personCountController,
      CategoryController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      child: Row(
        children: [
          Text(
              "${rows.where((i) => i["ingredientId"] != null).length} ingredient(s)",
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel",
                  style: TextStyle(
                      color: Color(0xFF4B5563), fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              if (selectedItemId.value == 0) {
                Get.snackbar("Error", "Please select an item first");
                return;
              }
              controller.createRecipe({
                "item": selectedItemId.value,
                "person_count": int.tryParse(personCountController.text) ?? 100,
                "ingredients":
                    rows.where((i) => i["ingredientId"] != null).toList(),
              });
            },
            icon: const Icon(Icons.save_outlined, size: 16),
            label: const Text("Save Ingredient",
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  static void showViewIngredients(
      BuildContext context, CategoryController controller, dynamic item) {
    controller.fetchRecipeForItem(item.id);

    // Dialog internal state
    final RxString dialogMode = "view".obs; // "view", "edit", "add"
    final RxList<Map<String, dynamic>> ingredientRows =
        <Map<String, dynamic>>[].obs;
    final personCountController = TextEditingController(text: "100");

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: context.width < 600 ? context.width - 20 : 800,
          constraints: BoxConstraints(maxHeight: context.height * 0.9),
          child: Obx(() {
            if (controller.isRecipeLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Fetching Recipe Details...",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            final recipes = controller.itemRecipeIngredients;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header - Changes based on mode
                _buildDynamicHeader(context, item, dialogMode.value, () {
                  if (dialogMode.value == "view") {
                    Get.back();
                  } else {
                    dialogMode.value = "view";
                  }
                }),
                const Divider(height: 1),

                // Body - Changes based on mode
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildDynamicBody(
                          context,
                          item,
                          controller,
                          dialogMode,
                          recipes,
                          ingredientRows,
                          personCountController),
                    ),
                  ),
                ),

                // Footer - Only for Add/Edit modes
                if (dialogMode.value != "view" &&
                    !(recipes.isEmpty && dialogMode.value == "view"))
                  _buildDynamicFooter(context, controller, item, dialogMode,
                      ingredientRows, personCountController),
              ],
            );
          }),
        ),
      ),
    );
  }

  static Widget _buildDynamicHeader(
      BuildContext context, dynamic item, String mode, VoidCallback onBack) {
    String title = "Recipe Ingredients Information";
    IconData icon = Icons.book_outlined;
    Color iconColor = AppColors.primary;

    if (mode == "edit") {
      title = "Edit Recipe";
      icon = Icons.edit_outlined;
    } else if (mode == "add") {
      title = "Add Recipe Ingredient";
      icon = Icons.add_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mode == "view" ? const Color(0xFFF9FAFB) : AppColors.primaryLight,
            Colors.white
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          if (mode != "view")
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          if (mode != "view") const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  mode == "view" ? AppColors.primaryLight : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: mode == "view" ? AppColors.primary : Colors.white,
                size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (mode == "view")
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (mode != "view")
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937)),
                  ),
                Text(
                    mode == "view"
                        ? "Recipe Ingredients Information"
                        : item.name,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, size: 20),
            style: IconButton.styleFrom(foregroundColor: Colors.grey),
          ),
        ],
      ),
    );
  }

  static Widget _buildDynamicBody(
      BuildContext context,
      dynamic item,
      CategoryController controller,
      RxString dialogMode,
      List<Map<String, dynamic>> recipes,
      RxList<Map<String, dynamic>> ingredientRows,
      TextEditingController personCountController) {
    if (dialogMode.value == "view") {
      if (recipes.isEmpty) {
        return _buildNoRecipeInnerView(item, context, () {
          // Initialize rows for Add Mode
          ingredientRows.value = [
            {"ingredientId": null, "quantity": "", "unit": "g"}
          ];
          personCountController.text = "100";
          dialogMode.value = "add";
        });
      }
      return _buildRecipeInnerView(item, context, controller, recipes, () {
        // Initialize rows for Edit Mode
        final existing = recipes.map((r) {
          final match = controller.ingredients
              .firstWhereOrNull((i) => i['name'] == r['name']);
          return {
            "id": r["id"],
            "ingredientId": match?['id'],
            "quantity": r["quantity"],
            "unit": r["unit"]
          };
        }).toList();

        ingredientRows.value = existing;
        // Add one empty row if needed
        ingredientRows.add({"ingredientId": null, "quantity": "", "unit": "g"});
        personCountController.text =
            controller.recipePersonCount.value.toString();
        dialogMode.value = "edit";
      });
    }

    // Add or Edit Mode UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
            Icons.people_outline, "RECIPE FOR PERSON COUNT", Colors.green),
        const SizedBox(height: 8),
        _buildPersonCountInput(personCountController),
        const SizedBox(height: 24),
        _buildSectionLabel(
            Icons.inventory_2_outlined, "INGREDIENTS", Colors.blue),
        const SizedBox(height: 16),
        _buildIngredientsTableHeader(),
        const SizedBox(height: 8),
        Obx(() => Column(
              children: List.generate(ingredientRows.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE8E0F3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: ingredientRows[index]["ingredientId"],
                              hint: const Text("Select ingredient",
                                  style: TextStyle(fontSize: 13)),
                              items: controller.ingredients
                                  .map((ing) => DropdownMenuItem(
                                        value: ing['id'] as int,
                                        child: Text(ing['name'] ?? 'Unknown',
                                            style:
                                                const TextStyle(fontSize: 13)),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                ingredientRows[index] = {
                                  ...ingredientRows[index],
                                  "ingredientId": v
                                };
                                if (index == ingredientRows.length - 1) {
                                  ingredientRows.add({
                                    "ingredientId": null,
                                    "quantity": "",
                                    "unit": "g"
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          onChanged: (v) => ingredientRows[index] = {
                            ...ingredientRows[index],
                            "quantity": v
                          },
                          controller: TextEditingController(
                              text: ingredientRows[index]["quantity"])
                            ..selection = TextSelection.fromPosition(
                                TextPosition(
                                    offset: ingredientRows[index]["quantity"]
                                        .toString()
                                        .length)),
                          decoration: InputDecoration(
                            hintText: "e.g. 100",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE8E0F3))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          onChanged: (v) => ingredientRows[index] = {
                            ...ingredientRows[index],
                            "unit": v
                          },
                          controller: TextEditingController(
                              text: ingredientRows[index]["unit"])
                            ..selection = TextSelection.fromPosition(
                                TextPosition(
                                    offset: ingredientRows[index]["unit"]
                                        .toString()
                                        .length)),
                          decoration: InputDecoration(
                            hintText: "g",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE8E0F3))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 32,
                        child: IconButton(
                          onPressed: index < ingredientRows.length - 1
                              ? () => ingredientRows.removeAt(index)
                              : null,
                          icon: const Icon(Icons.close,
                              size: 16, color: Colors.red),
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            )),
      ],
    );
  }

  static Widget _buildDynamicFooter(
      BuildContext context,
      CategoryController controller,
      dynamic item,
      RxString dialogMode,
      RxList<Map<String, dynamic>> ingredientRows,
      TextEditingController personCountController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Text(
            "${ingredientRows.where((i) => i["ingredientId"] != null).length} ingredient(s)",
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => dialogMode.value = "view",
            child: const Text("Cancel",
                style: TextStyle(
                    color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              final validIngredients = ingredientRows
                  .where((i) => i["ingredientId"] != null)
                  .toList();
              if (validIngredients.isEmpty) {
                Get.snackbar("Error", "Please add at least one ingredient");
                return;
              }

              await controller.createRecipe({
                "item": item.id,
                "person_count": int.tryParse(personCountController.text) ?? 100,
                "ingredients": validIngredients,
              });

              await controller.fetchRecipeForItem(item.id);
              dialogMode.value = "view";
            },
            icon: const Icon(Icons.save_outlined, size: 16),
            label: Text(
                dialogMode.value == "edit" ? "Save Changes" : "Save Ingredient",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNoRecipeInnerView(
      dynamic item, BuildContext context, VoidCallback onAdd) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.report_problem_rounded,
              color: Color(0xFFFFB020), size: 56),
        ),
        const SizedBox(height: 24),
        const Text("No Recipe Found",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827))),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
            children: [
              const TextSpan(
                  text: "There are no recipe ingredients mapped to "),
              TextSpan(
                  text: item.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const TextSpan(text: " yet."),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Add Recipe Ingredient",
              style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  static Widget _buildRecipeInnerView(
      dynamic item,
      BuildContext context,
      CategoryController controller,
      List<Map<String, dynamic>> recipes,
      VoidCallback onEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.width >= 600)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              children: [
                _buildCostBadge(
                    "BASE COST", "₹${item.baseCost ?? '0'}", Colors.green),
                const SizedBox(width: 8),
                _buildCostBadge(
                    "SEL. RATE", "₹${item.selectionRate ?? '0'}", Colors.blue),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.price_change_outlined, size: 18),
                  onPressed: () => showEditItemCosts(context, controller, item),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ],
            ),
          ),
        if (context.width < 600)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCostBadge(
                      "BASE COST", "₹${item.baseCost ?? '0'}", Colors.green),
                  const SizedBox(width: 8),
                  _buildCostBadge("SEL. RATE", "₹${item.selectionRate ?? '0'}",
                      Colors.blue),
                  const SizedBox(width: 8),
                  _buildPriceSimpleButton(context, controller, item),
                ],
              ),
            ),
          ),
        Row(
          children: [
            _buildTagBadge(Icons.people_outline,
                "${controller.recipePersonCount.value} Persons", Colors.green),
            const SizedBox(width: 12),
            _buildTagBadge(Icons.inventory_2_outlined,
                "${recipes.length} Ingredients", Colors.blue),
            const Spacer(),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text("Edit Recipe",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildIngredientsTableHeader(),
        const SizedBox(height: 8),
        ...recipes
            .map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(6)),
                          alignment: Alignment.center,
                          child: Text("${recipes.indexOf(r) + 1}",
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 3,
                            child: Text(r["name"] ?? "Unknown",
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF374151)))),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 2,
                            child: Text("${r["quantity"]} ${r["unit"]}",
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF6B7280)))),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  static void showEditItemCosts(
      BuildContext context, CategoryController controller, dynamic item) {
    final baseCostController =
        TextEditingController(text: item.baseCost.toString());
    final selectionRateController =
        TextEditingController(text: item.selectionRate.toString());

    Get.dialog(
      _DialogWrapper(
        title: "Edit Item Costs",
        subtitle: "Update pricing for '${item.name}'",
        icon: Icons.edit_outlined,
        onSave: () {
          final bc = double.tryParse(baseCostController.text) ?? 0;
          final sr = double.tryParse(selectionRateController.text) ?? 0;
          if (sr < bc) {
            Get.snackbar(
                "Error", "Selection Rate cannot be lower than Base Cost!");
            return;
          }
          controller.updateItemCosts(item.id, bc, sr);
          Get.back();
        },
        child: Column(
          children: [
            _buildPriceInput(
                "Base Cost (₹)", baseCostController, "Raw cost of the item"),
            const SizedBox(height: 16),
            _buildPriceInput(
                "Selection Rate (₹)", selectionRateController, "Customer rate"),
          ],
        ),
      ),
    );
  }

  static Widget _buildCostBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 0.5)),
          Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  static void showEditCategory(BuildContext context,
      CategoryController controller, int categoryId, String oldName) {
    final nameController = TextEditingController(text: oldName);

    Get.dialog(
      _DialogWrapper(
        title: "Edit Category",
        subtitle: "Rename your menu category",
        icon: Icons.edit_note_outlined,
        onSave: () =>
            controller.updateCategory(categoryId, nameController.text),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Category Name *",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Please Enter Category Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showSwapPosition(BuildContext context,
      CategoryController controller, int categoryId, String categoryName) {
    final positionController = TextEditingController();

    Get.dialog(
      _DialogWrapper(
        title: "Change Position",
        subtitle: "Change sorting order for '$categoryName'",
        icon: Icons.swap_vert_rounded,
        onSave: () {
          final pos = int.tryParse(positionController.text);
          if (pos != null) {
            controller.swapCategoryPosition(categoryId, pos);
          } else {
            Get.snackbar("Invalid", "Please enter a valid position number");
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("New Position *",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: positionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter relative position (e.g. 1, 2, 3...)",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showDeleteConfirmation({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 32),
              ),
              const SizedBox(height: 20),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text("Delete",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildTagBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  static Widget _buildPriceSimpleButton(
      BuildContext context, CategoryController controller, dynamic item) {
    return InkWell(
      onTap: () => showEditItemCosts(context, controller, item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          children: [
            Icon(Icons.edit_outlined, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text("Edit",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
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
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, Colors.white],
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
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ]),
                          child: Icon(icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937))),
                            Text(subtitle,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500)),
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
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20)),
                  border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel",
                          style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Save ${title.split(' ').last}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
