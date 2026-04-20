import 'package:get/get.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/providers/staff_provider.dart';

class StaffController extends GetxController {
  final StaffProvider _provider = StaffProvider();

  final isLoading = true.obs;
  final staffList = <StaffModel>[].obs;
  final roles = <String>[].obs;
  final waiterTypes = <WaiterTypeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final responses = await Future.wait([
        _provider.getAllStaff(),
        _provider.getRoles(),
        _provider.getWaiterTypes(),
      ]);

      if (responses[0].data != null) {
        final List data = (responses[0].data is Map) ? responses[0].data['data'] : responses[0].data;
        staffList.value = data.map((json) => StaffModel.fromJson(json)).toList();
      }

      if (responses[1].data != null) {
        final List data = responses[1].data;
        roles.value = data.map((json) => json['name'].toString()).toList();
      }

      if (responses[2].data != null) {
        final List data = responses[2].data;
        waiterTypes.value = data.map((json) => WaiterTypeModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch staff data");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      await _provider.deleteStaff(id);
      staffList.removeWhere((s) => s.id == id);
      Get.snackbar("Success", "Staff member deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete staff member");
    }
  }

  // Navigation Logic (To be connected to Add/Edit Views)
  void goToAddStaff() {
    // Get.to(() => const AddEditStaffView(mode: 'add'));
  }

  void goToEditStaff(StaffModel staff) {
    // Get.to(() => AddEditStaffView(mode: 'edit', staff: staff));
  }
}
