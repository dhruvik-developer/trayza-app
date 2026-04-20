import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class OrderProvider {
  Future<Response> getAllOrders({Map<String, dynamic>? params}) async {
    try {
      final response = await ApiClient.dio.get('/event-bookings/', queryParameters: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
