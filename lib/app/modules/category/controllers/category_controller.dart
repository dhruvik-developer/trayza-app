import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/category_provider.dart';

class CategoryController extends GetxController {
  final CategoryProvider _categoryProvider = CategoryProvider();

  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;

  // Master-Detail State
  final selectedCategoryId = RxnInt();
  final searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
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
        .where((i) => i.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final response = await _categoryProvider.getCategories();
      if (response.data['status'] == true) {
        final List data = response.data['data'];
        final fetched = data.map((e) => CategoryModel.fromJson(e)).toList();
        categories.assignAll(fetched);
        
        // Default selection to first category if none selected
        if (selectedCategoryId.value == null && categories.isNotEmpty) {
          selectedCategoryId.value = categories.first.id;
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories");
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
    try {
      final response = await _categoryProvider.createCategory(name);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchCategories();
        Get.back(); // Close modal
        Get.snackbar("Success", "Category created successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create category");
    }
  }

  Future<void> createItem(String name, int categoryId, double baseCost, double selectionRate) async {
    try {
      final response = await _categoryProvider.createItem(name, categoryId, baseCost, selectionRate);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchCategories();
        Get.back(); // Close modal
        Get.snackbar("Success", "Item created successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create item");
    }
  }

  Future<void> createRecipe(Map<String, dynamic> data) async {
    try {
      final response = await _categoryProvider.createRecipe(data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchCategories();
        Get.back(); // Close modal
        Get.snackbar("Success", "Recipe ingredient saved successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create recipe");
    }
  }
}
