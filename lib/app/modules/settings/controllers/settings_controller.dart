import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/business_profile_service.dart';

class SettingsController extends GetxController {
  bool isRefreshing = false;

  String get businessName {
    final service = _serviceOrNull;
    final name = service?.catersName?.trim();
    return (name == null || name.isEmpty)
        ? 'Business name not available'
        : name;
  }

  String? get logoUrl => _serviceOrNull?.logoUrl;
  String get fssaiNumber => _valueOrFallback(_serviceOrNull?.fssaiNumber);
  String get maskedFssaiNumber =>
      _maskTrailingDigits(_serviceOrNull?.fssaiNumber);
  String get phoneNumber => _valueOrFallback(_serviceOrNull?.phoneNumber);
  String get whatsappNumber => _valueOrFallback(_serviceOrNull?.whatsappNumber);
  String get address => _valueOrFallback(_serviceOrNull?.address);
  String get primaryColorCode => _toHex(primaryColor);

  Color get primaryColor =>
      _serviceOrNull?.primaryColor ?? const Color(0xFF845CBD);

  Future<void> refreshBusinessProfile() async {
    if (isRefreshing) return;

    final service = _serviceOrNull;
    if (service == null) {
      Get.snackbar('Unavailable', 'Business profile service is not ready yet.');
      return;
    }

    isRefreshing = true;
    update();

    await service.fetchProfile();

    isRefreshing = false;
    update();
    Get.snackbar('Updated', 'Business profile refreshed successfully.');
  }

  void showEditProfileComingSoon() {
    Get.snackbar(
      'Read only for now',
      'Edit profile flow will be added here soon.',
    );
  }

  BusinessProfileService? get _serviceOrNull =>
      Get.isRegistered<BusinessProfileService>()
          ? BusinessProfileService.to
          : null;

  String _valueOrFallback(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Not available';
    }
    return normalized;
  }

  String _maskTrailingDigits(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Not available';
    }

    if (normalized.length <= 4) {
      return normalized;
    }

    final visiblePrefixLength = normalized.length > 8 ? 4 : 2;
    final visiblePrefix = normalized.substring(0, visiblePrefixLength);
    final visibleSuffix = normalized.substring(normalized.length - 4);
    final hiddenLength = normalized.length - visiblePrefixLength - 4;

    return '$visiblePrefix${'*' * hiddenLength}$visibleSuffix';
  }

  String _toHex(Color color) {
    final red = color.r.round().toRadixString(16).padLeft(2, '0');
    final green = color.g.round().toRadixString(16).padLeft(2, '0');
    final blue = color.b.round().toRadixString(16).padLeft(2, '0');
    return '#${red.toUpperCase()}${green.toUpperCase()}${blue.toUpperCase()}';
  }
}
