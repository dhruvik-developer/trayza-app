import 'package:get/get.dart';

class GstBillingController extends GetxController {}

class GstBillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GstBillingController>(() => GstBillingController());
  }
}

class EventSummaryController extends GetxController {}

class EventSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventSummaryController>(() => EventSummaryController());
  }
}

class GroundChecklistController extends GetxController {}

class GroundChecklistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroundChecklistController>(() => GroundChecklistController());
  }
}
