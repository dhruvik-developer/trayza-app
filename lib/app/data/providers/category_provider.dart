import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class CategoryProvider {
  Future<Response> getCategories() async {
    try {
      final response = await ApiClient.dio.get('/categories/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createCategory(String name) async {
    try {
      final response = await ApiClient.dio.post('/categories/', data: {
        'name': name,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createItem(String name, int categoryId, double baseCost, double selectionRate) async {
    try {
      final response = await ApiClient.dio.post('/items/', data: {
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
      final response = await ApiClient.dio.post('/recipes/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getIngredientItems() async {
    try {
      final response = await ApiClient.dio.get('/ingredients-items/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAllItems() async {
    try {
      final response = await ApiClient.dio.get('/items/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
