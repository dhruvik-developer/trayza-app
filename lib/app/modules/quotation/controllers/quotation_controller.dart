import 'package:get/get.dart';

class QuotationController extends GetxController {
  final isLoading = false.obs;
}

class QuotationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuotationController>(() => QuotationController());
  }
}
