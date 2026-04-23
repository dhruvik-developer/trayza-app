import 'dart:developer';

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
  static const String _fssaiNumberKey = 'business_profile_fssai_number';
  static const String _phoneNumberKey = 'business_profile_phone_number';
  static const String _whatsappNumberKey = 'business_profile_whatsapp_number';
  static const String _addressKey = 'business_profile_address';

  late SharedPreferences _prefs;

  final RxnString _catersName = RxnString();
  final RxnString _logoUrl = RxnString();
  final RxnString _fssaiNumber = RxnString();
  final RxnString _phoneNumber = RxnString();
  final RxnString _whatsappNumber = RxnString();
  final RxnString _address = RxnString();
  final Rx<Color> _primaryColor = _defaultPrimaryColor.obs;
  final Rx<Color> _primaryLightColor = _defaultPrimaryLightColor.obs;

  String? get catersName => _catersName.value;
  String? get logoUrl => _logoUrl.value;
  String? get fssaiNumber => _fssaiNumber.value;
  String? get phoneNumber => _phoneNumber.value;
  String? get whatsappNumber => _whatsappNumber.value;
  String? get address => _address.value;
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
      final fssaiNumber = _readFirstProfileValue(profile, const [
        'fssai_number',
        'fssai_no',
        'fssai',
        'fssai_license_number',
      ]);
      final phoneNumber = _readFirstProfileValue(profile, const [
        'phone_number',
        'mobile_number',
        'contact_number',
        'phone',
      ]);
      final whatsappNumber = _readFirstProfileValue(profile, const [
        'whatsapp_number',
        'whatsapp_no',
        'whatsapp',
      ]);
      final address = _readFirstProfileValue(profile, const [
        'godown_office_address',
        'godown_address',
        'office_address',
        'address',
        'full_address',
      ]);
      final primaryColor = _parseHexColor(colorCode) ?? _defaultPrimaryColor;

      _catersName.value = catersName;
      _logoUrl.value = logoUrl;
      _fssaiNumber.value = fssaiNumber;
      _phoneNumber.value = phoneNumber;
      _whatsappNumber.value = whatsappNumber;
      _address.value = address;
      _primaryColor.value = primaryColor;
      _primaryLightColor.value = _buildPrimaryLight(primaryColor);
      log('${_logoUrl.value} LOGO URLSS');
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
      await _setOrRemoveString(_fssaiNumberKey, fssaiNumber);
      await _setOrRemoveString(_phoneNumberKey, phoneNumber);
      await _setOrRemoveString(_whatsappNumberKey, whatsappNumber);
      await _setOrRemoveString(_addressKey, address);
      await _prefs.setString(_colorCodeKey, _toHex(primaryColor));
    } catch (_) {
      // Keep cached/default branding if the API is temporarily unavailable.
    }
  }

  void _loadCachedProfile() {
    final cachedCatersName = _prefs.getString(_catersNameKey);
    final cachedLogoUrl = _prefs.getString(_logoUrlKey);
    final cachedColorCode = _prefs.getString(_colorCodeKey);
    final cachedFssaiNumber = _prefs.getString(_fssaiNumberKey);
    final cachedPhoneNumber = _prefs.getString(_phoneNumberKey);
    final cachedWhatsappNumber = _prefs.getString(_whatsappNumberKey);
    final cachedAddress = _prefs.getString(_addressKey);
    final cachedPrimaryColor =
        _parseHexColor(cachedColorCode) ?? _defaultPrimaryColor;

    _catersName.value = _normalizeText(cachedCatersName);
    _logoUrl.value =
        (cachedLogoUrl == null || cachedLogoUrl.isEmpty) ? null : cachedLogoUrl;
    _fssaiNumber.value = _normalizeText(cachedFssaiNumber);
    _phoneNumber.value = _normalizeText(cachedPhoneNumber);
    _whatsappNumber.value = _normalizeText(cachedWhatsappNumber);
    _address.value = _normalizeText(cachedAddress);
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

  String? _readFirstProfileValue(
    Map<String, dynamic> profile,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _normalizeText(profile[key]?.toString());
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  Future<void> _setOrRemoveString(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(key);
      return;
    }

    await _prefs.setString(key, value);
  }

  String _toHex(Color color) {
    final red = color.r.round().toRadixString(16).padLeft(2, '0');
    final green = color.g.round().toRadixString(16).padLeft(2, '0');
    final blue = color.b.round().toRadixString(16).padLeft(2, '0');
    return '#${red.toUpperCase()}${green.toUpperCase()}${blue.toUpperCase()}';
  }
}
