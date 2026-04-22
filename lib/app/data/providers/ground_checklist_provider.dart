import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class GroundChecklistProvider {
  Future<Response> getGroundCategories() async {
    return ApiClient.dio.get('/ground/categories/');
  }

  Future<Response> createGroundCategory(Map<String, dynamic> data) async {
    return ApiClient.dio.post('/ground/categories/', data: data);
  }

  Future<Response> updateGroundCategory(
      int id, Map<String, dynamic> data) async {
    return ApiClient.dio.put('/ground/categories/$id/', data: data);
  }

  Future<Response> deleteGroundCategory(int id) async {
    return ApiClient.dio.delete('/ground/categories/$id/');
  }

  Future<Response> createGroundItem(Map<String, dynamic> data) async {
    return ApiClient.dio.post('/ground/items/', data: data);
  }

  Future<Response> updateGroundItem(int id, Map<String, dynamic> data) async {
    return ApiClient.dio.put('/ground/items/$id/', data: data);
  }

  Future<Response> deleteGroundItem(int id) async {
    return ApiClient.dio.delete('/ground/items/$id/');
  }
}
