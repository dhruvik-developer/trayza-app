import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class StaffProvider {
  Future<Response> getAllStaff({Map<String, dynamic>? params}) async {
    try {
      final response = await ApiClient.dio.get('/staff/', queryParameters: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createStaff(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/staff/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateStaff(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.put('/staff/$id/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteStaff(int id) async {
    try {
      final response = await ApiClient.dio.delete('/staff/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getWaiterTypes() async {
    try {
      final response = await ApiClient.dio.get('/waiter-types/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Response> getRoles() async {
    try {
      final response = await ApiClient.dio.get('/roles/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
