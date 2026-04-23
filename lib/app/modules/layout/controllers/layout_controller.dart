import 'package:get/get.dart';

class LayoutController extends GetxController {
  final selectedIndex = 0.obs;

  void setIndex(int index) => selectedIndex.value = index;

  final menuItems = [
    {'title': 'Create Dish', 'icon': 'room_service'},
    {'title': 'Category', 'icon': 'category'},
    {'title': 'Order Management', 'icon': 'assignment'},
    {'title': 'Stock', 'icon': 'shopping_bag'},
    {'title': 'Payment History', 'icon': 'history'},
    {'title': 'Expense', 'icon': 'payments'},
    {'title': 'Create Ingredient', 'icon': 'note_add'},
    {'title': 'People', 'icon': 'people'},
    {'title': 'Ground Checklist', 'icon': 'rule_folder'},
  ];
}
