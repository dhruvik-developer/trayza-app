import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class RecipeProvider {
  Future<Response> getRecipes({int? itemId}) async {
    try {
      final params = itemId != null ? {'item_id': itemId} : <String, dynamic>{};
      final response = await ApiClient.dio.get('/recipes/', queryParameters: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addRecipe(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/recipes/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateRecipe(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.put('/recipes/$id/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteRecipe(int id) async {
    try {
      final response = await ApiClient.dio.delete('/recipes/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getIngredientItems() async {
    try {
      // Re-using the stock items endpoint for ingredient selection
      final response = await ApiClient.dio.get('/stoke-items/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
