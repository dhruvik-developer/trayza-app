import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_x;
import '../../routes/app_routes.dart';
import '../values/app_values.dart';
import '../../data/services/auth_service.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppValues.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ),
  );

  static Dio get dio {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AuthService.to.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          AuthService.to.logout();
          get_x.Get.offAllNamed(Routes.LOGIN);
        }
        return handler.next(e);
      },
    ));
    return _dio;
  }
}
