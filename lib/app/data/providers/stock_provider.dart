import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class StockProvider {
  // Categories
  Future<Response> getStockCategories() async {
    try {
      final response = await ApiClient.dio.get('/stoke-categories/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addStockCategory(String name) async {
    try {
      final response = await ApiClient.dio.post('/stoke-categories/', data: {'name': name});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteStockCategory(int id) async {
    try {
      final response = await ApiClient.dio.delete('/stoke-categories/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Items
  Future<Response> getStockItems({String? categoryId}) async {
    try {
      Map<String, dynamic> params = {};
      if (categoryId != null && categoryId != "all_items" && categoryId != "low_stock") {
        params['category'] = categoryId;
      } else if (categoryId == "low_stock") {
        params['low_stock'] = true;
      }
      
      final response = await ApiClient.dio.get('/stoke-items/', queryParameters: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addStockItem(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/stoke-items/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteStockItem(int id) async {
    try {
      final response = await ApiClient.dio.delete('/stoke-items/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Stock Adjustments
  Future<Response> increaseStock(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.put('/add-stoke-item/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> decreaseStock(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/add-stoke-item/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
