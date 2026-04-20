import 'package:get/get.dart';

class LayoutController extends GetxController {
  final selectedIndex = 0.obs;
  
  void setIndex(int index) => selectedIndex.value = index;
  
  // Exact Menu list from React Web Sidebar images (GST Billing Removed)
  final menuItems = [
    {'title': 'Create Dish', 'icon': 'room_service'},
    {'title': 'Category', 'icon': 'category'},
    {'title': 'Quotation', 'icon': 'assignment'},
    {'title': 'All Order', 'icon': 'checklist'},
    {'title': 'Invoice', 'icon': 'receipt'},
    {'title': 'Stock', 'icon': 'shopping_bag'},
    {'title': 'Payment History', 'icon': 'history'},
    {'title': 'Expense', 'icon': 'payments'},
    {'title': 'Create Ingredient', 'icon': 'note_add'},
    {'title': 'People', 'icon': 'people'},
    {'title': 'Event Summary', 'icon': 'description'},
    {'title': 'Ground Checklist', 'icon': 'rule_folder'},
  ];
}
