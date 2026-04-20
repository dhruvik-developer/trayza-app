import 'package:get/get.dart';
import '../../../data/providers/order_provider.dart';

class DashboardController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  
  final totalOrders = 0.obs;
  final pendingOrders = 0.obs;
  final totalRevenue = 0.0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final response = await _orderProvider.getAllOrders();
      if (response.data['status'] == true) {
        final List data = response.data['data'];
        totalOrders.value = data.length;
        pendingOrders.value = data.where((e) => e['status'] == 'pending').length;
        totalRevenue.value = data.fold(0.0, (sum, e) => sum + (e['total_amount'] ?? 0.0));
      }
    } catch (e) {
      print("Error fetching stats: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
