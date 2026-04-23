import 'package:get/get.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/category/bindings/category_binding.dart';
import '../modules/category/views/category_view.dart';
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/booking_view.dart';
import '../modules/layout/controllers/layout_controller.dart';
import '../modules/order_management/bindings/order_management_binding.dart';
import '../modules/order_management/views/order_management_view.dart';
import '../modules/order_management/widgets/order_management_tabs.dart';
import '../modules/people/bindings/people_binding.dart';
import '../modules/people/views/people_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/users/bindings/users_binding.dart';
import '../modules/users/views/users_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      bindings: [
        DashboardBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
    GetPage(
      name: Routes.ALL_ORDER,
      page: () => const OrderManagementView(
        initialSection: OrderManagementSection.allOrder,
      ),
      binding: OrderManagementBinding(),
    ),
    GetPage(
      name: Routes.QUOTATION,
      page: () => const OrderManagementView(
        initialSection: OrderManagementSection.quotation,
      ),
      binding: OrderManagementBinding(),
    ),
    GetPage(
      name: Routes.INVOICE,
      page: () => const OrderManagementView(
        initialSection: OrderManagementSection.invoice,
      ),
      binding: OrderManagementBinding(),
    ),
    GetPage(
      name: Routes.EVENT_SUMMARY,
      page: () => const OrderManagementView(
        initialSection: OrderManagementSection.eventSummary,
      ),
      binding: OrderManagementBinding(),
    ),
    GetPage(
      name: Routes.CATEGORY,
      page: () => const CategoryView(),
      bindings: [
        CategoryBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
    GetPage(
      name: Routes.DISH,
      page: () => const BookingView(),
      bindings: [
        BookingBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
    GetPage(
      name: Routes.PEOPLE,
      page: () => const PeopleView(),
      bindings: [
        PeopleBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
    GetPage(
      name: Routes.USERS,
      page: () => const UsersView(),
      bindings: [
        UsersBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      bindings: [
        SettingsBinding(),
        BindingsBuilder(() => Get.lazyPut(() => LayoutController())),
      ],
    ),
  ];
}
