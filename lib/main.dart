import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/login/views/login_view.dart';
import 'app/modules/login/bindings/login_binding.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  await initServices();
  
  runApp(
    GetMaterialApp(
      title: "Trayza Admin",
      home: const LoginView(),
      initialBinding: LoginBinding(),
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
