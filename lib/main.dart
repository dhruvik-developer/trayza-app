import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  await initServices();
  
  runApp(
    GetMaterialApp(
      title: "Trayza Admin",
      initialRoute: AppPages.INITIAL,
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
  print('Starting services...');
  await Get.putAsync(() => AuthService().init());
  print('All services started.');
}
