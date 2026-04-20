import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class AuthProvider {
  Future<Response> login(String username, String password) async {
    try {
      final response = await ApiClient.dio.post('/login/', data: {
        'username': username,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
