import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class ItemProvider {
  Future<Response> getItems() async {
    try {
      final response = await ApiClient.dio.get('/branch-items/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createItem(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/branch-items/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateItem(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.put('/branch-items/$id/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteItem(int id) async {
    try {
      final response = await ApiClient.dio.delete('/branch-items/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
