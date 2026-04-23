import 'package:dio/dio.dart';

import '../../core/utils/api_client.dart';

class UsersProvider {
  Future<Response> getUsers({Map<String, dynamic>? params}) async {
    try {
      return await ApiClient.dio.get('/users/', queryParameters: params);
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> createUser(Map<String, dynamic> data) async {
    try {
      return await ApiClient.dio.post('/users/', data: data);
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> updateUserPassword(int id, Map<String, dynamic> data) async {
    try {
      return await ApiClient.dio.post('/user/change-password/$id/', data: data);
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> deleteUser(int id) async {
    try {
      return await ApiClient.dio.delete('/users/$id/');
    } catch (error) {
      rethrow;
    }
  }
}
