import 'package:get/get.dart';

class LayoutController extends GetxController {
  final selectedIndex = 0.obs;
  
  void setIndex(int index) => selectedIndex.value = index;
  
  final menuItems = [
    {'title': 'Dashboard', 'icon': 'dashboard', 'route': '/dashboard'},
    {'title': 'Orders', 'icon': 'shopping_cart', 'route': '/all-order'},
    {'title': 'Dishes', 'icon': 'restaurant', 'route': '/dish'},
    {'title': 'Category', 'icon': 'category', 'route': '/category'},
    {'title': 'Ingredients', 'icon': 'inventory', 'route': '/recipe-ingredient'},
    {'title': 'People', 'icon': 'people', 'route': '/people'},
    {'title': 'Settings', 'icon': 'settings', 'route': '/settings'},
  ];
}
