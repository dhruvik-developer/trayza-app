import 'package:get/get.dart';
import '../../../data/models/recipe_model.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/recipe_provider.dart';

class RecipeController extends GetxController {
  final RecipeProvider _provider = RecipeProvider();

  // Route Params (Simulated since no named routes)
  final int itemId;
  final String itemName;
  
  RecipeController({required this.itemId, required this.itemName});

  // State
  final isLoading = true.obs;
  final isEditing = false.obs;
  final isAdding = false.obs;
  
  final recipeEntries = <RecipeModel>[].obs;
  final ingredientOptions = <StockItemModel>[].obs;
  
  final personCount = 100.obs;
  
  // Builder Logic
  final builderEntries = <BuilderRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecipeData();
  }

  Future<void> fetchRecipeData() async {
    isLoading.value = true;
    try {
      final responses = await Future.wait([
        _provider.getRecipes(itemId: itemId),
        _provider.getIngredientItems(),
      ]);

      if (responses[0].data != null) {
        final List data = responses[0].data;
        recipeEntries.value = data.map((json) => RecipeModel.fromJson(json)).toList();
        if (recipeEntries.isNotEmpty) {
          personCount.value = recipeEntries[0].personCount ?? 100;
        }
      }

      if (responses[1].data != null) {
        final List data = responses[1].data;
        ingredientOptions.value = data.map((json) => StockItemModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch recipe details");
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit() {
    builderEntries.value = recipeEntries.map((rec) => BuilderRow(
      id: rec.id,
      ingredientId: rec.ingredient?.id,
      quantity: rec.quantity ?? "",
      unit: rec.unit ?? "g",
    )).toList();
    
    // Add an empty row as per React logic
    addBuilderRow();
    isEditing.value = true;
  }

  void startAdd() {
    builderEntries.value = [BuilderRow(unit: "g")];
    isAdding.value = true;
  }

  void addBuilderRow() {
    builderEntries.add(BuilderRow(unit: "g"));
  }

  void removeBuilderRow(int index) {
    if (builderEntries.length > 1) {
      builderEntries.removeAt(index);
    }
  }

  void cancelAction() {
    isEditing.value = false;
    isAdding.value = false;
    builderEntries.clear();
  }

  Future<void> saveRecipe() async {
    isLoading.value = true;
    try {
      final validRows = builderEntries.where((row) => row.ingredientId != null && row.quantity.isNotEmpty).toList();
      
      for (var row in validRows) {
        final data = {
          'item': itemId,
          'ingredient': row.ingredientId,
          'quantity': row.quantity,
          'unit': row.unit,
          'person_count': personCount.value,
        };
        
        if (row.id != null) {
          await _provider.updateRecipe(row.id!, data);
        } else {
          await _provider.addRecipe(data);
        }
      }
      
      await fetchRecipeData();
      cancelAction();
      Get.snackbar("Success", "Recipe saved successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to save recipe");
    } finally {
      isLoading.value = false;
    }
  }
}

class BuilderRow {
  int? id;
  int? ingredientId;
  String quantity;
  String unit;

  BuilderRow({this.id, this.ingredientId, this.quantity = "", this.unit = "g"});
}
