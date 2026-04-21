import 'dart:developer';

import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/category_provider.dart';

class CategoryController extends GetxController {
  final CategoryProvider _categoryProvider = CategoryProvider();

  final categories = <CategoryModel>[].obs;
  final ingredients = <Map<String, dynamic>>[].obs;
  final itemRecipeIngredients = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isRecipeLoading = false.obs;
  final recipePersonCount = 100.obs;

  // Master-Detail State
  final selectedCategoryId = RxnInt();
  final searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchRecipeForItem(int itemId) async {
    isRecipeLoading.value = true;
    itemRecipeIngredients.clear();
    try {
      final response = await _categoryProvider.getRecipes();
      final List allRecipes =
          response.data is Map && response.data['data'] != null
              ? response.data['data']
              : (response.data is List ? response.data : []);

      // Filter for this item
      final itemRecipes = allRecipes.where((r) {
        if (r is! Map) return false;
        final id =
            r['item_id'] ?? (r['item'] is Map ? r['item']['id'] : r['item']);
        return id.toString() == itemId.toString();
      }).toList();

      if (itemRecipes.isNotEmpty) {
        recipePersonCount.value = itemRecipes.first['person_count'] ?? 100;

        final mapped = itemRecipes.map((r) {
          if (r is! Map) return <String, dynamic>{};

          // Get ingredient name
          String ingName = "";
          final ing = r['ingredient'];
          if (ing is Map) {
            ingName = ing['name'] ?? "";
          } else {
            // Match with our master ingredients list
            final match = ingredients
                .firstWhereOrNull((i) => i['id'].toString() == ing.toString());
            ingName = match?['name'] ?? "Unknown";
          }

          return {
            "name": ingName,
            "quantity": r['quantity']?.toString() ?? "0",
            "unit": r['unit'] ?? "g",
          };
        }).toList();

        itemRecipeIngredients.assignAll(mapped);
      }
    } catch (e) {
      log("Error fetching item recipe: $e");
    } finally {
      isRecipeLoading.value = false;
    }
  }

  // Reactive accessors
  CategoryModel? get selectedCategory {
    if (selectedCategoryId.value == null && categories.isNotEmpty) {
      return categories.first;
    }
    return categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);
  }

  List<CategoryItemModel> get filteredItems {
    final cat = selectedCategory;
    if (cat == null) return [];
    if (searchQuery.value.isEmpty) return cat.items;
    return cat.items
        .where((i) =>
            i.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final responses = await Future.wait([
        _categoryProvider.getCategories(),
        _categoryProvider.getRecipes(),
        _categoryProvider.getIngredientItems(),
      ]);

      final catResponse = responses[0];
      final recipeResponse = responses[1];
      final ingredientResponse = responses[2];

      // Extract Ingredient Items
      final List rawIngredients = ingredientResponse.data is Map &&
              ingredientResponse.data['data'] != null
          ? ingredientResponse.data['data']
          : (ingredientResponse.data is List ? ingredientResponse.data : []);
      ingredients
          .assignAll(rawIngredients.whereType<Map<String, dynamic>>().toList());

      // Extract recipes
      final List recipes =
          recipeResponse.data is Map && recipeResponse.data['data'] != null
              ? recipeResponse.data['data']
              : (recipeResponse.data is List ? recipeResponse.data : []);

      final recipeItemIds = recipes
          .map((r) {
            if (r is! Map) return null;
            final item = r['item'];
            final itemId = r['item_id'] ??
                (item is Map ? item['id'] : item) ??
                r['itemId'];
            return itemId?.toString();
          })
          .whereType<String>()
          .toSet();

      final recipeNames = recipes
          .map((r) {
            if (r is! Map) return null;
            final item = r['item'];
            final name = r['item_name'] ??
                (item is Map ? item['name'] : (item is String ? item : null)) ??
                r['itemName'];
            return name?.toString().toLowerCase().trim();
          })
          .whereType<String>()
          .toSet();

      // Extract categories
      List catData = [];
      if (catResponse.data is List) {
        catData = catResponse.data;
      } else if (catResponse.data is Map) {
        catData = catResponse.data['data'] ?? catResponse.data['results'] ?? [];
      }

      final List<CategoryModel> fetched = catData.map((e) {
        final cat = CategoryModel.fromJson(e);
        // Process items within category to check recipe status
        final processedItems = cat.items.map((item) {
          final isMatch = recipeItemIds.contains(item.id.toString()) ||
              recipeNames.contains(item.name.toLowerCase().trim());
          return item.copyWith(hasRecipe: isMatch);
        }).toList();

        return CategoryModel(
          id: cat.id,
          name: cat.name,
          description: cat.description,
          positions: cat.positions,
          items: processedItems,
        );
      }).toList();

      // Sort categories by positions like website
      fetched.sort((a, b) {
        if (a.positions == null) return 1;
        if (b.positions == null) return -1;
        return a.positions!.compareTo(b.positions!);
      });

      categories.assignAll(fetched);

      if (selectedCategoryId.value == null && categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
    } catch (e) {
      log("Error in fetchCategories: $e");
      Get.snackbar("Error", "Failed to fetch categories: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(int id) {
    selectedCategoryId.value = id;
    searchQuery.value = ""; // Reset search when switching categories
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  // --- CRUD Actions for Modals ---

  Future<void> createCategory(String name) async {
    if (name.isEmpty) {
      Get.snackbar("Required", "Category name is required");
      return;
    }

    // Title Case formatting like website
    final formattedName = name
        .trim()
        .split(" ")
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : "")
        .join(" ");

    // Duplicate check
    final isDuplicate = categories
        .any((c) => c.name.toLowerCase() == formattedName.toLowerCase());
    if (isDuplicate) {
      Get.snackbar("Error", "Category name already exists");
      return;
    }

    try {
      final response = await _categoryProvider.createCategory(formattedName);
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.data['status'] == true) {
        await fetchCategories();
        Get.back(); // Close modal
        Get.snackbar("Success", "Category created successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create category: ${e.toString()}");
    }
  }

  Future<void> createItem(String name, int categoryId, double baseCost,
      double selectionRate) async {
    if (name.isEmpty) {
      Get.snackbar("Required", "Item name is required");
      return;
    }

    // Title Case formatting
    final formattedName = name
        .trim()
        .split(" ")
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : "")
        .join(" ");

    // Duplicate check across ALL items in ALL categories (mirroring website)
    bool isDuplicate = false;
    for (var cat in categories) {
      if (cat.items.any(
          (item) => item.name.toLowerCase() == formattedName.toLowerCase())) {
        isDuplicate = true;
        break;
      }
    }

    if (isDuplicate) {
      Get.snackbar("Error", "Item name already exists");
      return;
    }

    if (selectionRate < baseCost) {
      Get.snackbar("Error", "Selection Rate cannot be lower than Base Cost!");
      return;
    }

    try {
      final response = await _categoryProvider.createItem(
          formattedName, categoryId, baseCost, selectionRate);
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.data['status'] == true) {
        await fetchCategories();
        Get.back(); // Close modal
        Get.snackbar("Success", "Item created successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create item: ${e.toString()}");
    }
  }

  Future<void> createRecipe(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final itemId = data['item'];
      final personCount = data['person_count'];
      final List ingredients = data['ingredients'] ?? [];

      if (ingredients.isEmpty) {
        Get.snackbar("Required", "Please add at least one ingredient");
        return;
      }

      // Parallell requests like website's Promise.all
      // Check for 'id' to decide between create and update
      await Future.wait(ingredients.map((ing) {
        final payload = {
          "item": itemId,
          "ingredient": ing["ingredientId"],
          "quantity": ing["quantity"],
          "unit": ing["unit"] ?? "g",
          "person_count": personCount,
        };

        if (ing["id"] != null) {
          return _categoryProvider.updateRecipe(ing["id"], payload);
        } else {
          return _categoryProvider.createRecipe(payload);
        }
      }));

      await fetchCategories();
      Get.back(); // Close modal
      Get.snackbar("Success", "Recipe saved successfully!");
    } catch (e) {
      log("Error in createRecipe: $e");
      Get.snackbar("Error", "Failed to save recipe: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItemCosts(
      int itemId, double baseCost, double selectionRate) async {
    if (selectionRate < baseCost) {
      Get.snackbar("Error", "Selection Rate cannot be lower than Base Cost!");
      return;
    }
    try {
      isLoading.value = true;
      final response =
          await _categoryProvider.putItemCosts(itemId, baseCost, selectionRate);
      if (response.statusCode == 200 || response.data['status'] == true) {
        await fetchCategories();
        Get.snackbar("Success", "Costs updated successfully!");
      }
    } catch (e) {
      log("Error updating costs: $e");
      Get.snackbar("Error", "Failed to update costs: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(int id, String name) async {
    if (name.isEmpty) {
      Get.snackbar("Required", "Category name is required");
      return;
    }
    try {
      final response = await _categoryProvider.editCategory(id, name);
      if (response.statusCode == 200 || response.data['status'] == true) {
        await fetchCategories();
        Get.back();
        Get.snackbar("Success", "Category updated successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update category: ${e.toString()}");
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await _categoryProvider.deleteCategory(id);
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.data['status'] == true) {
        if (selectedCategoryId.value == id) {
          selectedCategoryId.value = null;
        }
        await fetchCategories();
        Get.snackbar("Success", "Category deleted successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete category: ${e.toString()}");
    }
  }

  Future<void> deleteCategoryItem(int id) async {
    try {
      final response = await _categoryProvider.deleteItem(id);
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.data['status'] == true) {
        await fetchCategories();
        Get.snackbar("Success", "Item deleted successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete item: ${e.toString()}");
    }
  }

  Future<void> swapCategoryPosition(int id, int position) async {
    try {
      final response = await _categoryProvider.swapCategories(id, position);
      if (response.statusCode == 200 || response.data['status'] == true) {
        await fetchCategories();
        Get.back();
        Get.snackbar("Success", "Category position updated!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to swap categories: ${e.toString()}");
    }
  }
}
