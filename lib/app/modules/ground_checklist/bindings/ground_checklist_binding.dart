import 'package:get/get.dart';
import '../controllers/ground_checklist_controller.dart';

class GroundChecklistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroundChecklistController>(() => GroundChecklistController());
  }
}
