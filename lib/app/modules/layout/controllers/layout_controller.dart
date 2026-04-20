import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class LayoutController extends GetxController {
  final selectedIndex = 0.obs;
  
  void setIndex(int index) => selectedIndex.value = index;
  
  final menuItems = [
    {'title': 'Dashboard', 'icon': 'dashboard', 'route': Routes.DASHBOARD},
    {'title': 'Orders', 'icon': 'shopping_cart', 'route': Routes.ALL_ORDER},
    {'title': 'Dishes', 'icon': 'restaurant', 'route': Routes.DISH},
    {'title': 'Category', 'icon': 'category', 'route': Routes.CATEGORY},
    {'title': 'Ingredients', 'icon': 'inventory', 'route': '/recipe-ingredient'},
    {'title': 'People', 'icon': 'people', 'route': '/people'},
    {'title': 'Settings', 'icon': 'settings', 'route': '/settings'},
  ];
}
