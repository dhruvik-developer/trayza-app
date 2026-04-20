import 'package:get/get.dart';
import '../../../data/models/item_model.dart';
import '../../../data/providers/item_provider.dart';

class ItemController extends GetxController {
  final ItemProvider _provider = ItemProvider();

  // State
  final isLoading = false.obs;
  final categories = <ItemCategoryModel>[].obs;
  
  // Accordion Logic
  final expandedCategoryIds = <int>[].obs;
  
  // Selection Logic
  // Map of categoryId -> Set of selectedItemIds
  final selectedItems = <int, Set<int>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    try {
      final response = await _provider.getItems();
      if (response.data != null) {
        final List data = response.data;
        categories.value = data.map((json) => ItemCategoryModel.fromJson(json)).toList();
        // Sort by positions as per React logic
        categories.sort((a, b) => (a.positions ?? 0).compareTo(b.positions ?? 0));
        
        // Expand all by default or first one? React logic used collapsedIds state.
        // Let's expand first one by default.
        if (categories.isNotEmpty) {
          expandedCategoryIds.add(categories[0].id!);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch items");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleCategory(int categoryId) {
    if (expandedCategoryIds.contains(categoryId)) {
      expandedCategoryIds.remove(categoryId);
    } else {
      expandedCategoryIds.add(categoryId);
    }
  }

  void toggleItemSelection(int categoryId, int itemId) {
    if (!selectedItems.containsKey(categoryId)) {
      selectedItems[categoryId] = {itemId};
    } else {
      final items = selectedItems[categoryId]!;
      if (items.contains(itemId)) {
        items.remove(itemId);
        if (items.isEmpty) {
          selectedItems.remove(categoryId);
        }
      } else {
        items.add(itemId);
      }
    }
    selectedItems.refresh();
  }

  bool isItemSelected(int categoryId, int itemId) {
    return selectedItems[categoryId]?.contains(itemId) ?? false;
  }

  int getSelectedCount(int categoryId) {
    return selectedItems[categoryId]?.length ?? 0;
  }

  int getGrandTotalSelected() {
    int total = 0;
    selectedItems.forEach((key, value) {
      total += value.length;
    });
    return total;
  }
}
