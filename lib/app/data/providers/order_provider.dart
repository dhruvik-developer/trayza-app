import 'package:dio/dio.dart';

import '../../core/utils/api_client.dart';

class OrderProvider {
  Future<Response> getAllOrders({Map<String, dynamic>? params}) {
    return ApiClient.dio.get('/event-bookings/', queryParameters: params);
  }

  Future<Response> getPendingQuotations({Map<String, dynamic>? params}) {
    return ApiClient.dio.get(
      '/pending-event-bookings/',
      queryParameters: params,
    );
  }

  Future<Response> getOrderDetails(int id) {
    return ApiClient.dio.get('/event-bookings/$id/');
  }

  Future<Response> updateOrder(int id, Map<String, dynamic> payload) {
    return ApiClient.dio.put('/event-bookings/$id/', data: payload);
  }

  Future<Response> changeStatus(int id, String status) {
    return ApiClient.dio.post(
      '/status-change-event-bookings/$id/',
      data: {'status': status},
    );
  }

  Future<Response> addPayment(Map<String, dynamic> payload) {
    return ApiClient.dio.post('/payments/', data: payload);
  }
}
