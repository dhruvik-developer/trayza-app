import 'package:dio/dio.dart';

import '../../core/utils/api_client.dart';

class InvoiceProvider {
  Future<Response> getInvoices({Map<String, dynamic>? params}) {
    return ApiClient.dio.get('/payments/', queryParameters: params);
  }

  Future<Response> updatePayment(String id, Map<String, dynamic> payload) {
    return ApiClient.dio.put('/payments/$id/', data: payload);
  }
}
