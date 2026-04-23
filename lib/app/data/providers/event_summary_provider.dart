import 'package:dio/dio.dart';

import '../../core/utils/api_client.dart';

class EventSummaryProvider {
  Future<Response> getAssignments({Map<String, dynamic>? params}) {
    return ApiClient.dio.get('/event-assignments/', queryParameters: params);
  }

  Future<Response> updateAssignment(int id, Map<String, dynamic> payload) {
    return ApiClient.dio.patch('/event-assignments/$id/', data: payload);
  }
}
