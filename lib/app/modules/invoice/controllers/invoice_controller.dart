import 'package:get/get.dart';

class InvoiceController extends GetxController {
  final isLoading = false.obs;
}

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceController>(() => InvoiceController());
  }
}
