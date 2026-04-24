import 'package:get/get.dart';

import '../../../data/models/permission_models.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/providers/access_control_provider.dart';
import '../../../data/providers/staff_provider.dart';
import '../../../data/providers/vendor_provider.dart';

enum PeopleSection {
  eventStaff,
  vendor,
  waiterTypes,
  permissions,
}

class PeopleController extends GetxController {
  final StaffProvider _staffProvider = StaffProvider();
  final VendorProvider _vendorProvider = VendorProvider();
  final AccessControlProvider _accessControlProvider = AccessControlProvider();

  final isPageLoading = true.obs;
  final activeSection = PeopleSection.eventStaff.obs;

  final isStaffLoading = false.obs;
  final isVendorLoading = false.obs;
  final isWaiterTypeLoading = false.obs;
  final isPermissionsLoading = false.obs;
  final isPermissionSaving = false.obs;
  final isStaffSaving = false.obs;
  final isRolesLoading = false.obs;

  final staffList = <StaffModel>[].obs;
  final staffRoles = <Map<String, dynamic>>[].obs;
  final vendors = <VendorModel>[].obs;
  final waiterTypes = <WaiterTypeModel>[].obs;
  final permissionModules = <PermissionModuleModel>[].obs;
  final permissionSubjects = <PermissionSubjectModel>[].obs;
  final currentPermissions = <String>[].obs;

  final selectedPermissionType = 'staff'.obs;
  final selectedPermissionSubjectId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    isPageLoading.value = true;
    await Future.wait([
      fetchStaff(showErrorMessage: false),
      fetchStaffRoles(showErrorMessage: false),
      fetchVendors(showErrorMessage: false),
      fetchWaiterTypes(showErrorMessage: false),
      fetchPermissionModules(showErrorMessage: false),
      fetchPermissionSubjects(showErrorMessage: false),
    ]);
    isPageLoading.value = false;
  }

  void switchSection(PeopleSection section) {
    activeSection.value = section;
  }

  Future<void> fetchStaff({bool showErrorMessage = true}) async {
    isStaffLoading.value = true;
    try {
      final response = await _staffProvider.getAllStaff();
      final collection = _extractCollection(response.data);
      staffList.value = collection
          .whereType<Map>()
          .map((entry) => StaffModel.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (error) {
      if (showErrorMessage) {
        Get.snackbar('Error', _errorMessage(error, 'Failed to fetch staff'));
      }
    } finally {
      isStaffLoading.value = false;
    }
  }

  Future<void> fetchVendors({bool showErrorMessage = true}) async {
    isVendorLoading.value = true;
    try {
      final response = await _vendorProvider.getAllVendors();
      final collection = _extractCollection(response.data);
      vendors.value = collection
          .whereType<Map>()
          .map(
              (entry) => VendorModel.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (error) {
      if (showErrorMessage) {
        Get.snackbar('Error', _errorMessage(error, 'Failed to fetch vendors'));
      }
    } finally {
      isVendorLoading.value = false;
    }
  }

  Future<void> fetchStaffRoles({bool showErrorMessage = true}) async {
    isRolesLoading.value = true;
    try {
      final response = await _staffProvider.getRoles();
      final collection = _extractCollection(response.data);
      staffRoles.value = collection
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    } catch (error) {
      if (showErrorMessage) {
        Get.snackbar('Error', _errorMessage(error, 'Failed to fetch roles'));
      }
    } finally {
      isRolesLoading.value = false;
    }
  }

  Future<void> fetchWaiterTypes({bool showErrorMessage = true}) async {
    isWaiterTypeLoading.value = true;
    try {
      final response = await _staffProvider.getWaiterTypes();
      final collection = _extractCollection(response.data);
      waiterTypes.value = collection
          .whereType<Map>()
          .map((entry) =>
              WaiterTypeModel.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (error) {
      if (showErrorMessage) {
        Get.snackbar(
          'Error',
          _errorMessage(error, 'Failed to fetch waiter types'),
        );
      }
    } finally {
      isWaiterTypeLoading.value = false;
    }
  }

  Future<void> fetchPermissionModules({bool showErrorMessage = true}) async {
    try {
      final response = await _accessControlProvider.getPermissionModules();
      final collection = _extractCollection(response.data);
      permissionModules.value = collection
          .whereType<Map>()
          .map((entry) => PermissionModuleModel.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .where((module) => module.permissions.isNotEmpty)
          .toList();
    } catch (error) {
      if (showErrorMessage) {
        Get.snackbar(
          'Error',
          _errorMessage(error, 'Failed to fetch permission modules'),
        );
      }
    }
  }

  Future<void> fetchPermissionSubjects({bool showErrorMessage = true}) async {
    isPermissionsLoading.value = true;
    try {
      final response = await _accessControlProvider.getPermissionUsers(
        type: selectedPermissionType.value,
      );
      final collection = _extractCollection(response.data);
      permissionSubjects.value = collection
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .map((entry) {
            try {
              return PermissionSubjectModel.fromJson(entry);
            } on FormatException {
              return null;
            }
          })
          .whereType<PermissionSubjectModel>()
          .toList();
    } catch (error) {
      if (showErrorMessage) {
        Get.snackbar(
          'Error',
          _errorMessage(error, 'Failed to fetch permission users'),
        );
      }
    } finally {
      isPermissionsLoading.value = false;
    }
  }

  Future<void> selectPermissionType(String type) async {
    if (selectedPermissionType.value == type) return;
    selectedPermissionType.value = type;
    selectedPermissionSubjectId.value = null;
    currentPermissions.clear();
    await fetchPermissionSubjects();
  }

  Future<void> selectPermissionSubject(int id) async {
    selectedPermissionSubjectId.value = id;
    isPermissionsLoading.value = true;
    try {
      final response = await _accessControlProvider.getUserPermissions(id);
      currentPermissions.value = _normalizePermissionsFromResponse(
        response.data is Map<String, dynamic>
            ? response.data['data'] ?? response.data
            : response.data,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        _errorMessage(error, 'Failed to fetch user permissions'),
      );
    } finally {
      isPermissionsLoading.value = false;
    }
  }

  void togglePermission(String code) {
    if (currentPermissions.contains(code)) {
      currentPermissions.remove(code);
    } else {
      currentPermissions.add(code);
    }
  }

  Future<void> savePermissions() async {
    final subjectId = selectedPermissionSubjectId.value;
    if (subjectId == null) return;

    isPermissionSaving.value = true;
    try {
      await _accessControlProvider.updateUserPermissions(subjectId, {
        'allowed_permissions': currentPermissions.toList(),
        'denied_permissions': <String>[],
      });
      Get.snackbar('Success', 'Permissions updated successfully');
    } catch (error) {
      Get.snackbar(
        'Error',
        _errorMessage(error, 'Failed to update permissions'),
      );
    } finally {
      isPermissionSaving.value = false;
    }
  }

  Future<void> deleteStaffMember(int id) async {
    try {
      await _staffProvider.deleteStaff(id);
      staffList.removeWhere((entry) => entry.id == id);
      Get.snackbar('Success', 'Staff member deleted successfully');
    } catch (error) {
      Get.snackbar(
        'Error',
        _errorMessage(error, 'Failed to delete staff member'),
      );
    }
  }

  Future<void> deleteVendor(int id) async {
    try {
      await _vendorProvider.deleteVendor(id);
      vendors.removeWhere((entry) => entry.id == id);
      Get.snackbar('Success', 'Vendor deleted successfully');
    } catch (error) {
      Get.snackbar('Error', _errorMessage(error, 'Failed to delete vendor'));
    }
  }

  Future<Map<String, dynamic>?> fetchStaffDetails(
    int id, {
    bool showErrorMessage = true,
  }) async {
    try {
      final response = await _staffProvider.getSingleStaff(id);
      final entity = _extractEntity(response.data);
      if (entity is Map<String, dynamic>) {
        return entity;
      }
    } catch (error) {
      if (showErrorMessage) {
        Get.snackbar(
          'Error',
          _errorMessage(error, 'Failed to fetch staff details'),
        );
      }
    }
    return null;
  }

  Future<bool> createStaffMember(Map<String, dynamic> payload) async {
    isStaffSaving.value = true;
    try {
      await _staffProvider.createStaff(payload);
      await fetchStaff(showErrorMessage: false);
      Get.snackbar('Success', 'Staff member added successfully');
      return true;
    } catch (error) {
      Get.snackbar(
        'Error',
        _errorMessage(error, 'Failed to create staff member'),
      );
      return false;
    } finally {
      isStaffSaving.value = false;
    }
  }

  Future<bool> updateStaffMember(int id, Map<String, dynamic> payload) async {
    isStaffSaving.value = true;
    try {
      await _staffProvider.updateStaff(id, payload);
      await fetchStaff(showErrorMessage: false);
      Get.snackbar('Success', 'Staff member updated successfully');
      return true;
    } catch (error) {
      Get.snackbar(
        'Error',
        _errorMessage(error, 'Failed to update staff member'),
      );
      return false;
    } finally {
      isStaffSaving.value = false;
    }
  }

  Future<Map<String, dynamic>?> createStaffRole({
    required String name,
    String description = '',
  }) async {
    try {
      final response = await _staffProvider.createRole({
        'name': name.trim(),
        'description': description.trim(),
      });
      final entity = _extractEntity(response.data);
      if (entity is Map<String, dynamic>) {
        final createdRole = Map<String, dynamic>.from(entity);
        staffRoles.removeWhere(
          (role) => '${role['id']}' == '${createdRole['id']}',
        );
        staffRoles.add(createdRole);
        Get.snackbar('Success', 'Role created successfully');
        return createdRole;
      }
      await fetchStaffRoles(showErrorMessage: false);
    } catch (error) {
      Get.snackbar('Error', _errorMessage(error, 'Failed to create role'));
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchFixedStaffPaymentSummary(
    int staffId, {
    bool showErrorMessage = true,
  }) async {
    try {
      final response =
          await _staffProvider.getFixedStaffPaymentSummary(staffId);
      final entity = _extractEntity(response.data);
      if (entity is Map<String, dynamic>) {
        return entity;
      }
    } catch (error) {
      if (showErrorMessage) {
        Get.snackbar(
          'Error',
          _errorMessage(error, 'Failed to fetch payment summary'),
        );
      }
    }
    return null;
  }

  Future<void> addWaiterType({
    required String name,
    String? description,
    required double rate,
    required bool isActive,
  }) async {
    try {
      await _staffProvider.createWaiterType({
        'name': name.trim(),
        'description': description?.trim() ?? '',
        'per_person_rate': rate,
        'is_active': isActive,
      });
      await fetchWaiterTypes(showErrorMessage: false);
      Get.snackbar('Success', 'Waiter type created successfully');
    } catch (error) {
      Get.snackbar(
        'Error',
        _errorMessage(error, 'Failed to create waiter type'),
      );
    }
  }

  Future<void> updateWaiterType({
    required int id,
    required String name,
    String? description,
    required double rate,
    required bool isActive,
  }) async {
    try {
      await _staffProvider.updateWaiterType(id, {
        'name': name.trim(),
        'description': description?.trim() ?? '',
        'per_person_rate': rate,
        'is_active': isActive,
      });
      await fetchWaiterTypes(showErrorMessage: false);
      Get.snackbar('Success', 'Waiter type updated successfully');
    } catch (error) {
      Get.snackbar(
        'Error',
        _errorMessage(error, 'Failed to update waiter type'),
      );
    }
  }

  Future<void> deleteWaiterType(int id) async {
    try {
      await _staffProvider.deleteWaiterType(id);
      waiterTypes.removeWhere((entry) => entry.id == id);
      Get.snackbar('Success', 'Waiter type deleted successfully');
    } catch (error) {
      Get.snackbar(
        'Error',
        _errorMessage(error, 'Failed to delete waiter type'),
      );
    }
  }

  void showComingSoon(String message) {
    Get.snackbar('Coming Soon', message);
  }

  Map<String, dynamic>? findRole(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    for (final role in staffRoles) {
      final roleId = '${role['id']}'.trim();
      final roleLabel = roleName(role).toLowerCase();
      if (roleId == normalized || roleLabel == normalized.toLowerCase()) {
        return role;
      }
    }
    return null;
  }

  String roleName(dynamic role) {
    if (role is! Map) {
      final fallback = role?.toString().trim();
      return fallback == null || fallback.isEmpty ? 'Role' : fallback;
    }

    final normalized = Map<String, dynamic>.from(role);
    final label = (normalized['name'] ??
            normalized['role'] ??
            normalized['title'] ??
            normalized['label'])
        ?.toString()
        .trim();
    return label == null || label.isEmpty ? 'Role' : label;
  }

  bool isWaiterRole(dynamic roleValue) {
    return roleName(findRole(roleValue) ?? {'name': roleValue})
            .trim()
            .toLowerCase() ==
        'waiter';
  }

  List<dynamic> _extractCollection(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final nested = responseData['data'] ?? responseData['results'];
      if (nested is List) {
        return nested;
      }
      if (responseData.values.length == 1 && nested is Map<String, dynamic>) {
        final inner = nested['data'] ?? nested['results'];
        if (inner is List) {
          return inner;
        }
      }
    }

    if (responseData is List) {
      return responseData;
    }

    return const [];
  }

  dynamic _extractEntity(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final nested = responseData['data'] ??
          responseData['result'] ??
          responseData['item'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return responseData;
    }
    return responseData;
  }

  List<String> _normalizePermissionsFromResponse(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return const [];
    }

    List<String> normalizeList(List<dynamic> source) {
      return source
          .map((item) {
            if (item is String) return item.trim();
            if (item is Map<String, dynamic>) {
              return (item['code'] ??
                      item['permission_code'] ??
                      item['permission'])
                  .toString()
                  .trim();
            }
            return '';
          })
          .where((entry) => entry.isNotEmpty)
          .toSet()
          .toList();
    }

    final directPermissions = payload['direct_permissions'];
    if (directPermissions is List) {
      final allowedDirect = directPermissions.where((entry) {
        if (entry is String) return true;
        if (entry is Map<String, dynamic>) {
          return entry['is_allowed'] == true;
        }
        return false;
      }).toList();
      final codes = normalizeList(allowedDirect);
      if (codes.isNotEmpty) {
        return codes;
      }
    }

    final allowedPermissions = payload['allowed_permissions'];
    if (allowedPermissions is List) {
      final codes = normalizeList(allowedPermissions);
      if (codes.isNotEmpty) {
        return codes;
      }
    }

    final effectivePermissions = payload['effective_permissions'];
    if (effectivePermissions is List) {
      final codes = normalizeList(effectivePermissions);
      if (codes.isNotEmpty) {
        return codes;
      }
    }

    final permissionCodes = payload['permission_codes'];
    if (permissionCodes is List) {
      return normalizeList(permissionCodes);
    }

    return const [];
  }

  String _errorMessage(Object error, String fallback) {
    if (error is Exception) {
      final message = error.toString();
      if (message.isNotEmpty) {
        return message.replaceFirst('Exception: ', '');
      }
    }
    return fallback;
  }
}
