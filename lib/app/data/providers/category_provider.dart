import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class CategoryProvider {
  Future<Response> getCategories() async {
    try {
      final response = await ApiClient.dio.get('categories/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createCategory(String name) async {
    try {
      final response = await ApiClient.dio.post('categories/', data: {
        'name': name,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createItem(String name, int categoryId, double baseCost, double selectionRate) async {
    try {
      final response = await ApiClient.dio.post('items/', data: {
        'name': name,
        'category': categoryId,
        'base_cost': baseCost,
        'selection_rate': selectionRate,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createRecipe(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('recipes/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getRecipes() async {
    try {
      final response = await ApiClient.dio.get('recipes/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getIngredientItems() async {
    try {
      final response = await ApiClient.dio.get('ingredients-items/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAllItems() async {
    try {
      final response = await ApiClient.dio.get('items/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> editCategory(int id, String name) async {
    try {
      final response = await ApiClient.dio.put('categories/$id/', data: {
        'name': name,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteCategory(int id) async {
    try {
      final response = await ApiClient.dio.delete('categories/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteItem(int id) async {
    try {
      final response = await ApiClient.dio.delete('items/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> swapCategories(int id, int position) async {
    try {
      final response = await ApiClient.dio.post('category-positions-changes/$id/', data: {
        'positions': position,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateItemCosts(int id, double baseCost, double selectionRate) async {
    try {
      final response = await ApiClient.dio.put('items/$id/', data: {
        'base_cost': baseCost,
        'selection_rate': selectionRate,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateRecipe(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.put('recipes/$id/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> putItemCosts(
      int id, double baseCost, double selectionRate) async {
    try {
      final response = await ApiClient.dio.put('items/$id/', data: {
        'base_cost': baseCost,
        'selection_rate': selectionRate,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
