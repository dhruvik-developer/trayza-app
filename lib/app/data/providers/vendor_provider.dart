import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class VendorProvider {
  Future<Response> getAllVendors() async {
    try {
      final response = await ApiClient.dio.get('/vendors/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createVendor(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/vendors/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateVendor(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.put('/vendors/$id/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteVendor(int id) async {
    try {
      final response = await ApiClient.dio.delete('/vendors/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
