import 'package:get/get.dart';
import '../../../data/models/ingredient_model.dart';
import '../../../data/providers/ingredient_provider.dart';

class CreateIngredientController extends GetxController {
  final IngredientProvider _provider = IngredientProvider();

  final categories = <IngredientCategoryModel>[].obs;
  final isLoading = false.obs;

  // Master-Detail State
  final selectedCategoryId = RxnInt();
  final searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  IngredientCategoryModel? get selectedCategory {
    if (selectedCategoryId.value == null && categories.isNotEmpty) {
      return categories.first;
    }
    return categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);
  }

  List<IngredientItemModel> get filteredItems {
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
      final response = await _provider.getIngredientCategories();
      List data = [];

      // Robust response parsing
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map) {
        if (response.data.containsKey('data')) {
          data = response.data['data'];
        } else if (response.data.containsKey('results')) {
          data = response.data['results'];
        }
      }

      final fetched =
          data.map((e) => IngredientCategoryModel.fromJson(e)).toList();
      categories.assignAll(fetched);

      if (selectedCategoryId.value == null && categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
    } catch (e) {
      Get.snackbar(
          "Error", "Failed to fetch ingredient categories: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveIngredientCategory(String name, bool isCommon) async {
    if (name.trim().isEmpty) {
      Get.snackbar("Required", "Category name is required");
      return;
    }
    try {
      final response =
          await _provider.addIngredientCategory(name.trim(), isCommon);
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.data['status'] == true) {
        await fetchCategories();
        Get.back();
        Get.snackbar("Success", "Ingredient Category added successfully!");
      }
    } catch (e) {
      Get.snackbar(
          "Error", "Failed to add ingredient category: ${e.toString()}");
    }
  }

  Future<void> saveIngredientItem(String name, int categoryId) async {
    if (name.trim().isEmpty) {
      Get.snackbar("Required", "Item name is required");
      return;
    }
    try {
      final response =
          await _provider.addIngredientItem(name.trim(), categoryId);
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.data['status'] == true) {
        await fetchCategories();
        Get.back();
        Get.snackbar("Success", "Ingredient item created successfully!");
      }
    } catch (e) {
      Get.snackbar(
          "Error", "Failed to create ingredient item: ${e.toString()}");
    }
  }

  void selectCategory(int id) {
    selectedCategoryId.value = id;
    searchQuery.value = "";
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }
}

class CreateIngredientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateIngredientController>(() => CreateIngredientController());
  }
}
