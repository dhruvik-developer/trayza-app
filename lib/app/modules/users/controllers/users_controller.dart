import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/providers/users_provider.dart';

class UsersController extends GetxController {
  final UsersProvider _provider = UsersProvider();

  final isLoading = true.obs;
  final users = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final response = await _provider.getUsers();
      users.value = _extractUsers(response.data);
    } catch (error) {
      Get.snackbar('Error', _errorMessage(error, 'Failed to fetch users'));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addUser({
    required String username,
    String? email,
    required String password,
  }) async {
    try {
      final payload = <String, dynamic>{
        'username': username.trim(),
        'password': password,
      };

      final normalizedEmail = email?.trim();
      if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
        payload['email'] = normalizedEmail;
      }

      final response = await _provider.createUser(payload);
      await fetchUsers();
      Get.snackbar(
        'Success',
        _successMessage(response.data, 'User created successfully.'),
      );
      return true;
    } catch (error) {
      Get.snackbar('Error', _errorMessage(error, 'Failed to create user'));
      return false;
    }
  }

  Future<bool> updatePassword({
    required int userId,
    required String password,
  }) async {
    try {
      final response = await _provider.updateUserPassword(userId, {
        'new_password': password,
      });
      Get.snackbar(
        'Success',
        _successMessage(response.data, 'Password changed successfully.'),
      );
      return true;
    } catch (error) {
      Get.snackbar('Error', _errorMessage(error, 'Failed to update password'));
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      await _provider.deleteUser(userId);
      users.removeWhere((user) => user.id == userId);
      Get.snackbar('Success', 'User deleted successfully.');
      return true;
    } catch (error) {
      Get.snackbar('Error', _errorMessage(error, 'Failed to delete user'));
      return false;
    }
  }

  void showRulesMessage() {
    Get.snackbar(
      'Coming Soon',
      'Add Rule screen is not migrated in app yet.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  List<UserModel> _extractUsers(dynamic responseData) {
    final collection = responseData is Map<String, dynamic>
        ? responseData['data'] ?? responseData['results'] ?? responseData
        : responseData;

    if (collection is! List) {
      return const [];
    }

    return collection
        .whereType<Map>()
        .map((json) => UserModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  String _successMessage(dynamic responseData, String fallback) {
    if (responseData is Map<String, dynamic>) {
      final directMessage = responseData['message']?.toString().trim();
      if (directMessage != null && directMessage.isNotEmpty) {
        return directMessage;
      }

      final nestedData = responseData['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedMessage = nestedData['message']?.toString().trim();
        if (nestedMessage != null && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    return fallback;
  }

  String _errorMessage(Object error, String fallback) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          return message;
        }

        final detail = responseData['detail']?.toString().trim();
        if (detail != null && detail.isNotEmpty) {
          return detail;
        }

        for (final value in responseData.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first?.toString().trim();
            if (first != null && first.isNotEmpty) {
              return first;
            }
          }
          final normalized = value?.toString().trim();
          if (normalized != null && normalized.isNotEmpty) {
            return normalized;
          }
        }
      }
    }

    return fallback;
  }
}
