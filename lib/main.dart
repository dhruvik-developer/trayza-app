import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trayza_app/app/modules/bootstrap/views/app_bootstrap_screen.dart';

import 'app/core/theme/app_theme.dart';
import 'app/core/widgets/app_background.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/business_profile_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrayzaApp());
}

class TrayzaApp extends StatefulWidget {
  const TrayzaApp({super.key});

  @override
  State<TrayzaApp> createState() => _TrayzaAppState();
}

class _TrayzaAppState extends State<TrayzaApp> {
  static const Duration _minimumSplashDuration = Duration(seconds: 2);
  static const Color _fallbackPrimaryColor = Color(0xFF845CBD);

  bool _isReady = false;
  Object? _initializationError;
  String? _logoUrl;
  String? _catersName;
  Color _primaryColor = _fallbackPrimaryColor;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startedAt = DateTime.now();

    if (mounted) {
      setState(() {
        _isReady = false;
        _initializationError = null;
      });
    }

    try {
      final businessProfileService = await _initializeBusinessProfileService();
      _syncBranding(businessProfileService);

      if (mounted) {
        setState(() {});
      }

      await _initializeAuthService();

      final elapsed = DateTime.now().difference(startedAt);
      final remaining = _minimumSplashDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (!mounted) return;

      setState(() {
        _syncBranding(BusinessProfileService.to);
        _isReady = true;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _initializationError = error;
      });
    }
  }

  Future<BusinessProfileService> _initializeBusinessProfileService() async {
    if (Get.isRegistered<BusinessProfileService>()) {
      await BusinessProfileService.to.fetchProfile();
      return BusinessProfileService.to;
    }

    return Get.putAsync(() => BusinessProfileService().init());
  }

  Future<AuthService> _initializeAuthService() async {
    if (Get.isRegistered<AuthService>()) {
      return AuthService.to;
    }

    return Get.putAsync(() => AuthService().init());
  }

  void _syncBranding(BusinessProfileService service) {
    _logoUrl = service.logoUrl;
    _catersName = service.catersName;
    _primaryColor = service.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        title: 'Trayza Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: AppBootstrapScreen(
          logoUrl: _logoUrl,
          catersName: _catersName,
          primaryColor: _primaryColor,
          error: _initializationError,
          onRetry: _initializeApp,
        ),
      );
    }

    return GetMaterialApp(
      title: 'Trayza Admin',
      initialRoute: AuthService.to.isLoggedIn ? Routes.DISH : Routes.LOGIN,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      defaultTransition: Transition.cupertino,
      builder: (context, child) => AppBackground(
        primaryColor: _primaryColor,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
