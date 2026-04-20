import 'package:get/get.dart';
import '../controllers/all_order_controller.dart';

class AllOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllOrderController>(
      () => AllOrderController(),
    );
  }
}
