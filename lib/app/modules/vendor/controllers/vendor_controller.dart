import 'package:get/get.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/providers/vendor_provider.dart';

class VendorController extends GetxController {
  final VendorProvider _provider = VendorProvider();

  final isLoading = true.obs;
  final vendors = <VendorModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVendors();
  }

  Future<void> fetchVendors() async {
    isLoading.value = true;
    try {
      final response = await _provider.getAllVendors();
      if (response.data != null) {
        final List data = (response.data is Map) ? response.data['data'] : response.data;
        vendors.value = data.map((json) => VendorModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch vendors");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVendor(int id) async {
    try {
      await _provider.deleteVendor(id);
      vendors.removeWhere((v) => v.id == id);
      Get.snackbar("Success", "Vendor deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete vendor");
    }
  }
}

class VendorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorController>(() => VendorController());
  }
}
