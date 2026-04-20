import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class IngredientProvider {
  Future<Response> getIngredientCategories() async {
    try {
      final response = await ApiClient.dio.get('/ingredients-categories/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addIngredientCategory(String name, bool isCommon) async {
    try {
      final response = await ApiClient.dio.post('/ingredients-categories/', data: {
        'name': name,
        'is_common': isCommon,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addIngredientItem(String name, int categoryId) async {
    try {
      final response = await ApiClient.dio.post('/ingredients-items/', data: {
        'name': name,
        'category': categoryId,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
