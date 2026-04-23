import 'package:get/get.dart';

import '../../all_order/controllers/all_order_controller.dart';
import '../../event_summary/controllers/event_summary_controller.dart';
import '../../invoice/controllers/invoice_controller.dart';
import '../../layout/controllers/layout_controller.dart';
import '../../quotation/controllers/quotation_controller.dart';

class OrderManagementBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LayoutController>()) {
      Get.lazyPut<LayoutController>(() => LayoutController());
    }
    if (!Get.isRegistered<QuotationController>()) {
      Get.lazyPut<QuotationController>(() => QuotationController());
    }
    if (!Get.isRegistered<AllOrderController>()) {
      Get.lazyPut<AllOrderController>(() => AllOrderController());
    }
    if (!Get.isRegistered<InvoiceController>()) {
      Get.lazyPut<InvoiceController>(() => InvoiceController());
    }
    if (!Get.isRegistered<EventSummaryController>()) {
      Get.lazyPut<EventSummaryController>(() => EventSummaryController());
    }
  }
}
