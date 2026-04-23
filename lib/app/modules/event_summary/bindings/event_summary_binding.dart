import 'package:get/get.dart';

import '../controllers/event_summary_controller.dart';

class EventSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventSummaryController>(() => EventSummaryController());
  }
}
