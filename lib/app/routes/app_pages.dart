import 'package:get/get.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/all_order/bindings/all_order_binding.dart';
import '../modules/all_order/views/all_order_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/category/bindings/category_binding.dart';
import '../modules/category/views/category_view.dart';
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/booking_view.dart';
import '../modules/layout/controllers/layout_controller.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      bindings: [
        DashboardBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
    GetPage(
      name: _Paths.ALL_ORDER,
      page: () => const AllOrderView(),
      bindings: [
        AllOrderBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
    GetPage(
      name: _Paths.CATEGORY,
      page: () => const CategoryView(),
      bindings: [
        CategoryBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
    GetPage(
      name: _Paths.DISH, // Mapping /dish (wizard)
      page: () => const BookingView(),
      bindings: [
        BookingBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
  ];
}
