import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/values/app_values.dart';

class BusinessProfileService extends GetxService {
  static BusinessProfileService get to => Get.find();

  static const Color _defaultPrimaryColor = Color(0xFF845CBD);
  static const Color _defaultPrimaryLightColor = Color(0xFFF4EFFC);
  static const String _catersNameKey = 'business_profile_caters_name';
  static const String _logoUrlKey = 'business_profile_logo_url';
  static const String _colorCodeKey = 'business_profile_color_code';

  late SharedPreferences _prefs;

  final RxnString _catersName = RxnString();
  final RxnString _logoUrl = RxnString();
  final Rx<Color> _primaryColor = _defaultPrimaryColor.obs;
  final Rx<Color> _primaryLightColor = _defaultPrimaryLightColor.obs;

  String? get catersName => _catersName.value;
  String? get logoUrl => _logoUrl.value;
  Color get primaryColor => _primaryColor.value;
  Color get primaryLightColor => _primaryLightColor.value;

  Future<BusinessProfileService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCachedProfile();
    await fetchProfile();
    return this;
  }

  Future<void> fetchProfile() async {
    try {
      final response = await Dio(
        BaseOptions(
          baseUrl: AppValues.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.json,
        ),
      ).get('business-profiles/');

      final responseData = response.data;
      if (responseData is! Map) return;

      final data = responseData['data'];
      if (data is! List || data.isEmpty || data.first is! Map) return;

      final profile = Map<String, dynamic>.from(data.first as Map);
      final catersName = _normalizeText(profile['caters_name']?.toString());
      final logoUrl = _normalizeLogoUrl(profile['logo']?.toString());
      final colorCode = profile['color_code']?.toString();
      final primaryColor = _parseHexColor(colorCode) ?? _defaultPrimaryColor;

      _catersName.value = catersName;
      _logoUrl.value = logoUrl;
      _primaryColor.value = primaryColor;
      _primaryLightColor.value = _buildPrimaryLight(primaryColor);

      if (catersName == null) {
        await _prefs.remove(_catersNameKey);
      } else {
        await _prefs.setString(_catersNameKey, catersName);
      }
      if (logoUrl == null || logoUrl.isEmpty) {
        await _prefs.remove(_logoUrlKey);
      } else {
        await _prefs.setString(_logoUrlKey, logoUrl);
      }
      await _prefs.setString(_colorCodeKey, _toHex(primaryColor));
    } catch (_) {
      // Keep cached/default branding if the API is temporarily unavailable.
    }
  }

  void _loadCachedProfile() {
    final cachedCatersName = _prefs.getString(_catersNameKey);
    final cachedLogoUrl = _prefs.getString(_logoUrlKey);
    final cachedColorCode = _prefs.getString(_colorCodeKey);
    final cachedPrimaryColor =
        _parseHexColor(cachedColorCode) ?? _defaultPrimaryColor;

    _catersName.value = _normalizeText(cachedCatersName);
    _logoUrl.value =
        (cachedLogoUrl == null || cachedLogoUrl.isEmpty) ? null : cachedLogoUrl;
    _primaryColor.value = cachedPrimaryColor;
    _primaryLightColor.value = _buildPrimaryLight(cachedPrimaryColor);
  }

  String? _normalizeText(String? value) {
    if (value == null) return null;

    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return null;

    return trimmedValue;
  }

  String? _normalizeLogoUrl(String? logoUrl) {
    if (logoUrl == null || logoUrl.trim().isEmpty) return null;

    final trimmedUrl = logoUrl.trim();
    final parsedLogoUrl = Uri.tryParse(trimmedUrl);
    if (parsedLogoUrl != null && parsedLogoUrl.hasScheme) {
      return parsedLogoUrl.toString();
    }

    final baseUri = Uri.parse(AppValues.apiBaseUrl);
    return baseUri.resolve(trimmedUrl).toString();
  }

  Color? _parseHexColor(String? colorCode) {
    if (colorCode == null || colorCode.trim().isEmpty) return null;

    final sanitized = colorCode.trim().replaceFirst('#', '');
    final normalized = sanitized.length == 6 ? 'FF$sanitized' : sanitized;
    if (normalized.length != 8) return null;

    try {
      return Color(int.parse(normalized, radix: 16));
    } catch (_) {
      return null;
    }
  }

  Color _buildPrimaryLight(Color color) {
    return Color.alphaBlend(color.withValues(alpha: 0.12), Colors.white);
  }

  String _toHex(Color color) {
    final red = color.r.round().toRadixString(16).padLeft(2, '0');
    final green = color.g.round().toRadixString(16).padLeft(2, '0');
    final blue = color.b.round().toRadixString(16).padLeft(2, '0');
    return '#${red.toUpperCase()}${green.toUpperCase()}${blue.toUpperCase()}';
  }
}
