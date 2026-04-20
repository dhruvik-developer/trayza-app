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
}
