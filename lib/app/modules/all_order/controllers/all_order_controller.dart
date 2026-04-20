import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';

class AllOrderController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final response = await _orderProvider.getAllOrders();
      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        orders.assignAll(data.map((e) => OrderModel.fromJson(e)).toList());
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch orders");
    } finally {
      isLoading.value = false;
    }
  }
}
