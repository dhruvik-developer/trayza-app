import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/business_profile_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  await initServices();

  runApp(
    GetMaterialApp(
      title: "Trayza Admin",
      initialRoute: AuthService.to.isLoggedIn ? Routes.DISH : Routes.LOGIN,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      defaultTransition: Transition.cupertino,
    ),
  );
}

Future<void> initServices() async {
  await Get.putAsync(() => BusinessProfileService().init());
  await Get.putAsync(() => AuthService().init());
}
