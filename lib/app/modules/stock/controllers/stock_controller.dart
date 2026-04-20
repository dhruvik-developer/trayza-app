import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/stock_provider.dart';

class StockController extends GetxController {
  final StockProvider _provider = StockProvider();

  // State
  final isLoading = false.obs;
  final categories = <StockCategoryModel>[].obs;
  final items = <StockItemModel>[].obs;
  final selectedCategoryId = "all_items".obs;

  // Stats
  final totalItems = 0.obs;
  final lowStockItems = 0.obs;
  final totalValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchCategories(),
        fetchItems(),
      ]);
      calculateStats();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _provider.getStockCategories();
      if (response.data != null) {
        final List data = response.data;
        categories.value = data.map((json) => StockCategoryModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories");
    }
  }

  Future<void> fetchItems() async {
    try {
      final response = await _provider.getStockItems(
        categoryId: selectedCategoryId.value == "all_items" ? null : selectedCategoryId.value
      );
      if (response.data != null) {
        final List data = response.data;
        items.value = data.map((json) => StockItemModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch items");
    }
  }

  void calculateStats() {
    totalItems.value = items.length;
    lowStockItems.value = items.where((item) {
      final qty = double.tryParse(item.quantity ?? "0") ?? 0;
      final alert = double.tryParse(item.alert ?? "0") ?? 0;
      return qty <= alert;
    }).length;
    
    totalValue.value = items.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item.totalPrice ?? "0") ?? 0);
    });
  }

  void onCategoryChanged(String? id) {
    if (id != null) {
      selectedCategoryId.value = id;
      fetchItems();
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _provider.deleteStockItem(id);
      items.removeWhere((item) => item.id == id);
      calculateStats();
      Get.snackbar("Success", "Item deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete item");
    }
  }

  // To be implemented: Increase/Decrease methods
}
