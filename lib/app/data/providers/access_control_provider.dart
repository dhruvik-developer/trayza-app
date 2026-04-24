import 'package:dio/dio.dart';

import '../../core/utils/api_client.dart';

class AccessControlProvider {
  Future<Response> getPermissionModules() async {
    try {
      return await ApiClient.dio.get('/access-control/modules/');
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getPermissionUsers({String type = ''}) async {
    try {
      final params = type.trim().isEmpty ? null : {'user_type': type.trim()};
      return await ApiClient.dio.get(
        '/access-control/users/',
        queryParameters: params,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getUserPermissions(int userId) async {
    try {
      return await ApiClient.dio
          .get('/access-control/users/$userId/permissions/');
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> updateUserPermissions(
    int userId,
    Map<String, dynamic> data,
  ) async {
    try {
      return await ApiClient.dio.put(
        '/access-control/users/$userId/permissions/',
        data: data,
      );
    } catch (error) {
      rethrow;
    }
  }
}
