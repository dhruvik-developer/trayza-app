import 'package:get/get.dart';

class LayoutController extends GetxController {
  final selectedIndex = 0.obs;
  
  void setIndex(int index) => selectedIndex.value = index;
  
  // Menu items based on React Project structure
  final menuItems = [
    {'title': 'Dashboard', 'icon': 'dashboard'},
    {'title': 'All Orders', 'icon': 'assignment'},
    {'title': 'Create Dish', 'icon': 'restaurant_menu'}, // This is the Booking Wizard
    {'title': 'Stocks', 'icon': 'inventory_2'},
    {'title': 'Items', 'icon': 'list_alt'},
    {'title': 'People', 'icon': 'people'},
    {'title': 'Expense', 'icon': 'payments'},
    {'title': 'GST Billing', 'icon': 'receipt_long'},
    {'title': 'Settings', 'icon': 'settings'},
  ];
}
