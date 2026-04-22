import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class PaymentHistoryProvider {
  Future<Response> getPaymentHistory({Map<String, dynamic>? params}) async {
    try {
      final response = await ApiClient.dio.get(
        '/all-transaction/',
        queryParameters: params,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
