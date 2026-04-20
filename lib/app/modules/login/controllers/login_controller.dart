import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../booking/views/booking_view.dart';
import '../../booking/bindings/booking_binding.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final showPassword = false.obs;

  void toggleShowPassword() => showPassword.toggle();

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authProvider.login(
        usernameController.text,
        passwordController.text,
      );

      if (response.data['status'] == true) {
        final data = response.data['data'];
        final tokens = data['tokens'];
        final access = tokens['access'];
        final username = data['username'];
        final userType = data['user_type'];
        log(userType);
        if (userType == "admin") {
          AuthService.to.login(access, username, userType);
          Get.offAll(() => const BookingView(), binding: BookingBinding());
          Get.snackbar("Success", "Login successful",
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar("Error", "Only admin users are allowed to log in.",
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", response.data['message'] ?? "Login failed",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Login failed. Please check your credentials.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
