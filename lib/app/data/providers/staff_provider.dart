import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class StaffProvider {
  Future<Response> getAllStaff({Map<String, dynamic>? params}) async {
    try {
      final response =
          await ApiClient.dio.get('/staff/', queryParameters: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSingleStaff(int id) async {
    try {
      final response = await ApiClient.dio.get('/staff/$id/');
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
      final response = await ApiClient.dio.patch('/staff/$id/', data: data);
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

  Future<Response> createWaiterType(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/waiter-types/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateWaiterType(int id, Map<String, dynamic> data) async {
    try {
      final response =
          await ApiClient.dio.patch('/waiter-types/$id/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteWaiterType(int id) async {
    try {
      final response = await ApiClient.dio.delete('/waiter-types/$id/');
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

  Future<Response> createRole(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/roles/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getFixedStaffPaymentSummary(int staffId) async {
    try {
      final response =
          await ApiClient.dio.get('/staff/$staffId/fixed-payment-summary/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
