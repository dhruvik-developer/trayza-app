import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/staff_controller.dart';

class StaffView extends GetView<StaffController> {
  const StaffView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 600;

    return LayoutView(
      activeIndex: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              shadows: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.staffList.isEmpty) {
                    return _buildEmptyState();
                  }
                  return Expanded(
                    child: isMobile 
                      ? _buildStaffList() 
                      : _buildStaffTable(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF4EFFC), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Event Staff", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Obx(() => Text("${controller.staffList.length} staff registered", style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: controller.goToAddStaff,
          icon: const Icon(Icons.person_add_rounded, size: 18),
          label: const Text("Add Staff"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffTable() {
    return ListView.builder(
      itemCount: controller.staffList.length,
      itemBuilder: (context, index) {
        final staff = controller.staffList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              _buildAvatar(staff),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staff.name ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(staff.mobile ?? "-", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staff.role ?? "No Role", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                    _buildTypeTag(staff.type),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text("₹${staff.salary?.toStringAsFixed(0) ?? '0'}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _buildActions(staff),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(staff) {
    return Container(
      width: 44, height: 44,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, Color(0xFFAC94F4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          staff.name != null ? staff.name!.substring(0, 1).toUpperCase() : "?",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTypeTag(String? type) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFDDD6FE))),
      child: Text(type?.toUpperCase() ?? "STAFF", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
    );
  }

  Widget _buildActions(staff) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.grey), onPressed: () => controller.goToEditStaff(staff)),
        IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), onPressed: () => controller.deleteStaff(staff.id!)),
      ],
    );
  }

  Widget _buildStaffList() {
    return ListView.builder(
      itemCount: controller.staffList.length,
      itemBuilder: (context, index) {
        final staff = controller.staffList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _buildAvatar(staff),
            title: Text(staff.name ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${staff.role ?? 'No Role'} • ${staff.type ?? 'Fixed'}"),
            trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No staff members found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: controller.goToAddStaff, child: const Text("Register First Staff")),
        ],
      ),
    );
  }
}
