import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/permission_models.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/people_controller.dart';

class PeopleView extends GetView<PeopleController> {
  const PeopleView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 7,
      headerTitle: 'People',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE9F6FF),
                Color(0xFFF8FBFF),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  children: [
                    _PeopleTabsBar(isMobile: isMobile),
                    SizedBox(height: isMobile ? 16 : 24),
                    Expanded(
                      child: Obx(() {
                        if (controller.isPageLoading.value) {
                          return const _CenteredLoader(
                              message: 'Loading people module...');
                        }

                        return _PeopleSectionCard(
                          child: _buildActiveSection(context, isMobile),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSection(BuildContext context, bool isMobile) {
    switch (controller.activeSection.value) {
      case PeopleSection.eventStaff:
        return _EventStaffSection(isMobile: isMobile);
      case PeopleSection.vendor:
        return _VendorSection(isMobile: isMobile);
      case PeopleSection.waiterTypes:
        return _WaiterTypesSection(isMobile: isMobile);
      case PeopleSection.permissions:
        return _PermissionsSection(isMobile: isMobile);
    }
  }
}

class _PeopleTabsBar extends GetView<PeopleController> {
  const _PeopleTabsBar({required this.isMobile});

  final bool isMobile;

  static const List<_PeopleTabData> _tabs = [
    _PeopleTabData(
      section: PeopleSection.eventStaff,
      label: 'Event Staff',
      icon: Icons.groups_2_outlined,
    ),
    _PeopleTabData(
      section: PeopleSection.vendor,
      label: 'Vendor',
      icon: Icons.local_shipping_outlined,
    ),
    _PeopleTabData(
      section: PeopleSection.waiterTypes,
      label: 'Waiter Types',
      icon: Icons.work_outline_rounded,
    ),
    // _PeopleTabData(
    //   section: PeopleSection.permissions,
    //   label: 'Permissions',
    //   icon: Icons.lock_outline_rounded,
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 14),
      decoration: BoxDecoration(
        color: isMobile ? Colors.white.withValues(alpha: 0.86) : Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 28 : 24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isMobile ? 0.12 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: isMobile ? 22 : 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isMobile
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == _tabs.length - 1 ? 0 : 8,
                    ),
                    child: SizedBox(
                      width: 166,
                      child: Obx(
                        () => _PeopleTabButton(
                          data: tab,
                          isMobile: isMobile,
                          isActive:
                              controller.activeSection.value == tab.section,
                          onTap: () => controller.switchSection(tab.section),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            )
          : Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == _tabs.length - 1 ? 0 : 14,
                    ),
                    child: Obx(
                      () => _PeopleTabButton(
                        data: tab,
                        isMobile: isMobile,
                        isActive: controller.activeSection.value == tab.section,
                        onTap: () => controller.switchSection(tab.section),
                      ),
                    ),
                  ),
                );
              }),
            ),
    );
  }
}

class _PeopleTabButton extends StatelessWidget {
  const _PeopleTabButton({
    required this.data,
    required this.isMobile,
    required this.isActive,
    required this.onTap,
  });

  final _PeopleTabData data;
  final bool isMobile;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconBoxSize = isMobile ? 46.0 : 62.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 20,
            vertical: isMobile ? 12 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      const Color(0xFF0F7FCF),
                      AppColors.primary,
                      const Color(0xFF3EA5E8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : const Color(0xFFF3F8FC),
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.18)
                  : const Color(0xFFD7E7F4),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: iconBoxSize,
                width: iconBoxSize,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
                ),
                child: Icon(
                  data.icon,
                  size: isMobile ? 22 : 28,
                  color: isActive ? Colors.white : AppColors.primary,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      data.label,
                      maxLines: isMobile ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color:
                            isActive ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleSectionCard extends StatelessWidget {
  const _PeopleSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }
}

class _EventStaffSection extends GetView<PeopleController> {
  const _EventStaffSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EventStaffPanelHeader(
          isMobile: isMobile,
          staffCount: controller.staffList.length,
          onAddStaff: () => _showStaffDialog(context),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isStaffLoading.value) {
              return const _CenteredLoader(message: 'Loading staff...');
            }
            if (controller.staffList.isEmpty) {
              return const _EmptyState(
                icon: Icons.groups_2_outlined,
                title: 'No staff available',
                description:
                    'Use the Add Staff button to register staff members and they will appear here.',
              );
            }

            return isMobile
                ? _EventStaffMobileList(
                    staffList: controller.staffList,
                    onEdit: (staff) => _showStaffDialog(
                      context,
                      existing: staff,
                    ),
                    onDelete: (staff) => _confirmDeleteStaff(context, staff),
                    onViewPayments: (staff) =>
                        _showPaymentSummaryDialog(context, staff),
                  )
                : _EventStaffTable(
                    staffList: controller.staffList,
                    onEdit: (staff) => _showStaffDialog(
                      context,
                      existing: staff,
                    ),
                    onDelete: (staff) => _confirmDeleteStaff(context, staff),
                    onViewPayments: (staff) =>
                        _showPaymentSummaryDialog(context, staff),
                  );
          }),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteStaff(
    BuildContext context,
    StaffModel staff,
  ) async {
    if (staff.id == null) return;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Delete Staff'),
              content: Text(
                'Delete ${staff.name ?? 'this staff member'} from Event Staff?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed) {
      await controller.deleteStaffMember(staff.id!);
    }
  }

  Future<void> _showStaffDialog(
    BuildContext context, {
    StaffModel? existing,
  }) async {
    if (controller.staffRoles.isEmpty && !controller.isRolesLoading.value) {
      await controller.fetchStaffRoles(showErrorMessage: false);
      if (!context.mounted) return;
    }

    Map<String, dynamic>? details;
    if (existing?.id != null) {
      await _runWithBlockingLoader(
        context,
        () async => details = await controller.fetchStaffDetails(existing!.id!),
      );
      if (!context.mounted) return;
      if (details == null) {
        return;
      }
    }

    String? normalizeRoleValue(dynamic value) {
      final matchedRole = controller.findRole(value);
      if (matchedRole != null && matchedRole['id'] != null) {
        return '${matchedRole['id']}';
      }

      final normalized = value?.toString().trim();
      if (normalized == null || normalized.isEmpty) {
        return null;
      }
      return normalized;
    }

    final defaultRoleId = controller.staffRoles.isNotEmpty
        ? '${controller.staffRoles.first['id']}'
        : null;
    final nameController = TextEditingController(
      text: details?['name']?.toString() ?? existing?.name ?? '',
    );
    final phoneController = TextEditingController(
      text: details?['phone']?.toString() ??
          details?['mobile']?.toString() ??
          existing?.mobile ??
          '',
    );
    final fixedSalaryController = TextEditingController(
      text: details?['fixed_salary']?.toString() ??
          details?['monthly_salary']?.toString() ??
          (existing?.fixedSalary?.toStringAsFixed(2) ?? ''),
    );
    final perPersonRateController = TextEditingController(
      text: details?['per_person_rate']?.toString() ??
          (existing?.perPersonRate?.toStringAsFixed(2) ?? ''),
    );
    final joiningDateController = TextEditingController(
      text: details?['joining_date']?.toString().split('T').first ?? '',
    );
    final loginUsernameController = TextEditingController(
      text: details?['login_username']?.toString() ??
          details?['linked_username']?.toString() ??
          '',
    );
    final loginPasswordController = TextEditingController();
    final loginEmailController = TextEditingController(
      text: details?['login_email']?.toString() ??
          details?['email']?.toString() ??
          '',
    );

    var selectedRoleValue = normalizeRoleValue(
          details?['role'] is Map
              ? details?['role']?['id']
              : details?['role_id'] ??
                  details?['role'] ??
                  details?['role_name'] ??
                  existing?.role,
        ) ??
        defaultRoleId ??
        '';
    var selectedWaiterTypeId = (details?['waiter_type'] is Map
            ? details?['waiter_type']?['id']
            : details?['waiter_type_id'] ?? details?['waiter_type'])
        ?.toString();
    var selectedStaffType = details?['staff_type']?.toString() ??
        existing?.displayType ??
        'Contract';
    var isActive = details?['is_active'] is bool
        ? details!['is_active'] as bool
        : existing?.isActive ?? true;
    final hasExistingLogin = details?['linked_user_id'] != null ||
        details?['linked_username'] != null ||
        details?['user_account'] != null;
    var loginEnabled = hasExistingLogin ||
        loginUsernameController.text.trim().isNotEmpty ||
        loginEmailController.text.trim().isNotEmpty;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final showWaiterType = controller.isWaiterRole(selectedRoleValue);
            final isFixedStaff =
                selectedStaffType.trim().toLowerCase() == 'fixed';

            Future<void> saveStaff() async {
              final name = nameController.text.trim();
              final phone =
                  phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final fixedSalary =
                  double.tryParse(fixedSalaryController.text.trim()) ?? 0;
              final perPersonRate =
                  double.tryParse(perPersonRateController.text.trim()) ?? 0;
              final loginEmail = loginEmailController.text.trim();
              final loginPassword = loginPasswordController.text.trim();
              final roleId = int.tryParse(selectedRoleValue);
              final waiterTypeId = int.tryParse(selectedWaiterTypeId ?? '');

              if (name.isEmpty) {
                Get.snackbar('Error', 'Staff name is required');
                return;
              }
              if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                Get.snackbar('Error', 'Phone number must be exactly 10 digits');
                return;
              }
              if (roleId == null) {
                Get.snackbar('Error', 'Please select a role');
                return;
              }
              if (showWaiterType && waiterTypeId == null) {
                Get.snackbar('Error', 'Please select a waiter type');
                return;
              }
              if (isFixedStaff) {
                if (fixedSalary <= 0) {
                  Get.snackbar('Error', 'Fixed salary must be greater than 0');
                  return;
                }
                if (joiningDateController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Joining date is required');
                  return;
                }
              } else if (perPersonRate <= 0) {
                Get.snackbar(
                  'Error',
                  'Per person rate must be greater than 0',
                );
                return;
              }
              if (loginEnabled && loginUsernameController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Login username is required');
                return;
              }
              if (loginEnabled &&
                  !hasExistingLogin &&
                  loginPasswordController.text.trim().length < 4) {
                Get.snackbar(
                  'Error',
                  'Login password must be at least 4 characters',
                );
                return;
              }
              if (loginEmail.isNotEmpty &&
                  !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(loginEmail)) {
                Get.snackbar('Error', 'Enter a valid login email');
                return;
              }

              final payload = <String, dynamic>{
                'name': name,
                'phone': phone,
                'role': roleId,
                'staff_type': selectedStaffType,
                'fixed_salary': isFixedStaff ? fixedSalary.toString() : null,
                'waiter_type': showWaiterType ? waiterTypeId : null,
                'per_person_rate':
                    isFixedStaff ? '0.00' : perPersonRate.toString(),
                'is_active': isActive,
                'joining_date':
                    isFixedStaff ? joiningDateController.text.trim() : null,
              };

              if (loginEnabled) {
                payload['login_username'] = loginUsernameController.text.trim();
                if (loginEmail.isNotEmpty) {
                  payload['login_email'] = loginEmail;
                }
                if (loginPassword.isNotEmpty) {
                  payload['login_password'] = loginPassword;
                }
              }

              final success = existing?.id == null
                  ? await controller.createStaffMember(payload)
                  : await controller.updateStaffMember(existing!.id!, payload);
              if (success && context.mounted) {
                Navigator.of(dialogContext).pop();
              }
            }

            return Dialog(
              insetPadding: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              existing == null
                                  ? Icons.person_add_alt_1_rounded
                                  : Icons.edit_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  existing == null
                                      ? 'Add New Staff'
                                      : 'Edit Staff Member',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Register or update event staff details with the same fields used on the website.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Status',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Control whether this staff member is active',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: isActive,
                              activeColor: AppColors.primary,
                              onChanged: (value) => setState(
                                () => isActive = value,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 390,
                            child: _DialogField(
                              label: 'Full Name',
                              controller: nameController,
                              hintText: 'e.g. Bhautik Barvaliya',
                            ),
                          ),
                          SizedBox(
                            width: 390,
                            child: _DialogField(
                              label: 'Phone Number',
                              controller: phoneController,
                              hintText: 'e.g. 9876543210',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          SizedBox(
                            width: 390,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Role',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: selectedRoleValue.isEmpty
                                            ? null
                                            : selectedRoleValue,
                                        decoration: _dialogInputDecoration(
                                          hintText: 'Select role',
                                        ),
                                        items: controller.staffRoles
                                            .map(
                                              (role) => DropdownMenuItem(
                                                value: '${role['id']}',
                                                child: Text(
                                                  controller.roleName(role),
                                                ),
                                              ),
                                            )
                                            .toList(growable: false),
                                        onChanged: (value) => setState(() {
                                          selectedRoleValue = value ?? '';
                                          if (!controller.isWaiterRole(value)) {
                                            selectedWaiterTypeId = null;
                                          }
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () async {
                                        final createdRole =
                                            await _showAddRoleDialog(context);
                                        if (createdRole != null) {
                                          setState(() {
                                            selectedRoleValue =
                                                '${createdRole['id']}';
                                            if (!controller.isWaiterRole(
                                              selectedRoleValue,
                                            )) {
                                              selectedWaiterTypeId = null;
                                            }
                                          });
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        height: 56,
                                        width: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.10),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (showWaiterType)
                            SizedBox(
                              width: 390,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Waiter Type',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: selectedWaiterTypeId,
                                    decoration: _dialogInputDecoration(
                                      hintText: 'Select waiter type',
                                    ),
                                    items: controller.waiterTypes
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: '${type.id}',
                                            child: Text(type.name ?? 'Waiter'),
                                          ),
                                        )
                                        .toList(growable: false),
                                    onChanged: (value) => setState(
                                      () => selectedWaiterTypeId = value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Login Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Linked Login',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    hasExistingLogin
                                        ? 'Existing linked login found. You can update it here.'
                                        : 'Optional login account for this staff member',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: loginEnabled,
                              activeColor: AppColors.primary,
                              onChanged: (value) => setState(() {
                                loginEnabled = hasExistingLogin || value;
                                if (!loginEnabled) {
                                  loginUsernameController.clear();
                                  loginPasswordController.clear();
                                  loginEmailController.clear();
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                      if (loginEnabled) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: 390,
                              child: _DialogField(
                                label: 'Login Username',
                                controller: loginUsernameController,
                                hintText: 'e.g. staff_username',
                              ),
                            ),
                            SizedBox(
                              width: 390,
                              child: _DialogField(
                                label: hasExistingLogin
                                    ? 'New Password (Optional)'
                                    : 'Login Password',
                                controller: loginPasswordController,
                                hintText: hasExistingLogin
                                    ? 'Leave blank to keep current password'
                                    : 'Minimum 4 characters',
                              ),
                            ),
                            SizedBox(
                              width: 796,
                              child: _DialogField(
                                label: 'Login Email',
                                controller: loginEmailController,
                                hintText: 'e.g. staff@example.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Employment & Financials',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: ['Fixed', 'Agency', 'Contract']
                            .map(
                              (type) => ChoiceChip(
                                label: Text(type),
                                selected: selectedStaffType == type,
                                onSelected: (_) => setState(() {
                                  selectedStaffType = type;
                                  if (type == 'Fixed') {
                                    perPersonRateController.text = '0.00';
                                  } else {
                                    fixedSalaryController.clear();
                                    joiningDateController.clear();
                                  }
                                }),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selectedStaffType == type
                                      ? AppColors.primary
                                      : const Color(0xFF4B5563),
                                ),
                                backgroundColor: Colors.white,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.10),
                                side: BorderSide(
                                  color: selectedStaffType == type
                                      ? AppColors.primary
                                          .withValues(alpha: 0.30)
                                      : const Color(0xFFE5E7EB),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          if (isFixedStaff)
                            SizedBox(
                              width: 390,
                              child: _DialogField(
                                label: 'Fixed Salary (Monthly)',
                                controller: fixedSalaryController,
                                hintText: 'e.g. 50000',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                          if (isFixedStaff)
                            SizedBox(
                              width: 390,
                              child: _DialogField(
                                label: 'Joining Date',
                                controller: joiningDateController,
                                hintText: 'Select joining date',
                                readOnly: true,
                                onTap: () async {
                                  final initialDate = DateTime.tryParse(
                                        joiningDateController.text.trim(),
                                      ) ??
                                      DateTime.now();
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2018),
                                    lastDate: DateTime(2100),
                                    initialDate: initialDate,
                                  );
                                  if (pickedDate != null) {
                                    joiningDateController.text = pickedDate
                                        .toIso8601String()
                                        .split('T')
                                        .first;
                                  }
                                },
                              ),
                            ),
                          if (!isFixedStaff)
                            SizedBox(
                              width: 390,
                              child: _DialogField(
                                label: 'Per Person Rate',
                                controller: perPersonRateController,
                                hintText: 'e.g. 500',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => ElevatedButton.icon(
                              onPressed: controller.isStaffSaving.value
                                  ? null
                                  : saveStaff,
                              icon: controller.isStaffSaving.value
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      existing == null
                                          ? Icons.person_add_alt_1_rounded
                                          : Icons.check_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                existing == null ? 'Add Staff' : 'Save Changes',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    fixedSalaryController.dispose();
    perPersonRateController.dispose();
    joiningDateController.dispose();
    loginUsernameController.dispose();
    loginPasswordController.dispose();
    loginEmailController.dispose();
  }

  Future<Map<String, dynamic>?> _showAddRoleDialog(BuildContext context) async {
    final roleNameController = TextEditingController();
    final descriptionController = TextEditingController();
    Map<String, dynamic>? createdRole;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Role',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create a new staff role without leaving the drawer.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogField(
                    label: 'Role Name',
                    controller: roleNameController,
                    hintText: 'e.g. Helper Chef',
                  ),
                  const SizedBox(height: 14),
                  _DialogField(
                    label: 'Description',
                    controller: descriptionController,
                    hintText: 'Short description (optional)',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final roleName = roleNameController.text.trim();
                          if (roleName.isEmpty) {
                            Get.snackbar('Error', 'Role name is required');
                            return;
                          }
                          createdRole = await controller.createStaffRole(
                            name: roleName,
                            description: descriptionController.text,
                          );
                          if (createdRole != null && context.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Create Role'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    roleNameController.dispose();
    descriptionController.dispose();
    return createdRole;
  }

  Future<void> _showPaymentSummaryDialog(
    BuildContext context,
    StaffModel staff,
  ) async {
    if (staff.id == null) return;

    Map<String, dynamic>? summary;
    await _runWithBlockingLoader(
      context,
      () async =>
          summary = await controller.fetchFixedStaffPaymentSummary(staff.id!),
    );
    if (summary == null || !context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
            child: _FixedStaffPaymentSummaryDialog(summary: summary!),
          ),
        );
      },
    );
  }

  Future<void> _runWithBlockingLoader(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    try {
      await action();
    } finally {
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }
}

class _VendorSection extends GetView<PeopleController> {
  const _VendorSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.local_shipping_outlined,
          title: 'Vendor',
          subtitleBuilder: () {
            final count = controller.vendors.length;
            return '$count vendor${count == 1 ? '' : 's'} registered';
          },
          actionLabel: 'Add Vendor',
          actionIcon: Icons.add_business_rounded,
          onAction: () => controller.showComingSoon(
            'Add vendor form is not migrated in the app yet.',
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isVendorLoading.value) {
              return const _CenteredLoader(message: 'Loading vendors...');
            }
            if (controller.vendors.isEmpty) {
              return const _EmptyState(
                icon: Icons.local_shipping_outlined,
                title: 'No vendors available',
                description:
                    'Use the Add Vendor button to register vendors and they will appear here.',
              );
            }

            return isMobile
                ? _VendorMobileList(vendors: controller.vendors)
                : _VendorTable(vendors: controller.vendors);
          }),
        ),
      ],
    );
  }
}

class _WaiterTypesSection extends GetView<PeopleController> {
  const _WaiterTypesSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.work_outline_rounded,
          title: 'Waiter Types',
          subtitleBuilder: () {
            final count = controller.waiterTypes.length;
            return '$count waiter type${count == 1 ? '' : 's'} available';
          },
          actionLabel: 'Add Waiter Type',
          actionIcon: Icons.add_rounded,
          onAction: () => _showWaiterTypeDialog(context),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isWaiterTypeLoading.value) {
              return const _CenteredLoader(message: 'Loading waiter types...');
            }
            if (controller.waiterTypes.isEmpty) {
              return const _EmptyState(
                icon: Icons.work_outline_rounded,
                title: 'No waiter types available',
                description:
                    'Create waiter categories and they will appear here for event planning.',
              );
            }

            return isMobile
                ? _WaiterTypesMobileList(
                    waiterTypes: controller.waiterTypes,
                    onEdit: (type) => _showWaiterTypeDialog(
                      context,
                      existing: type,
                    ),
                  )
                : _WaiterTypesTable(
                    waiterTypes: controller.waiterTypes,
                    onEdit: (type) => _showWaiterTypeDialog(
                      context,
                      existing: type,
                    ),
                  );
          }),
        ),
      ],
    );
  }

  Future<void> _showWaiterTypeDialog(
    BuildContext context, {
    WaiterTypeModel? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final rateController = TextEditingController(
      text: existing?.rate?.toStringAsFixed(0) ?? '',
    );
    var isActive = existing?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              existing == null
                                  ? Icons.add_rounded
                                  : Icons.edit_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  existing == null
                                      ? 'Add Waiter Type'
                                      : 'Edit Waiter Type',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Manage waiter categories and their per-person pricing.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _DialogField(
                        label: 'Type Name',
                        controller: nameController,
                        hintText: 'e.g. Captain, Server, Bartender',
                      ),
                      const SizedBox(height: 16),
                      _DialogField(
                        label: 'Description',
                        controller: descriptionController,
                        hintText: 'Brief description (optional)',
                      ),
                      const SizedBox(height: 16),
                      _DialogField(
                        label: 'Per Person Rate',
                        controller: rateController,
                        hintText: 'e.g. 500',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SwitchListTile.adaptive(
                        value: isActive,
                        onChanged: (value) => setState(() => isActive = value),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        title: const Text(
                          'Active status',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                          'Available for selection in event planning',
                          style: TextStyle(fontSize: 12),
                        ),
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              final rate = double.tryParse(
                                rateController.text.trim(),
                              );

                              if (name.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Waiter type name is required',
                                );
                                return;
                              }
                              if (rate == null) {
                                Get.snackbar(
                                  'Error',
                                  'Valid per person rate is required',
                                );
                                return;
                              }

                              if (existing == null) {
                                await controller.addWaiterType(
                                  name: name,
                                  description: descriptionController.text,
                                  rate: rate,
                                  isActive: isActive,
                                );
                              } else if (existing.id != null) {
                                await controller.updateWaiterType(
                                  id: existing.id!,
                                  name: name,
                                  description: descriptionController.text,
                                  rate: rate,
                                  isActive: isActive,
                                );
                              }

                              if (context.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(existing == null ? 'Create' : 'Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    rateController.dispose();
  }
}

class _PermissionsSection extends GetView<PeopleController> {
  const _PermissionsSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final mobileLeftPanelHeight =
        (MediaQuery.sizeOf(context).height * 0.34).clamp(260.0, 360.0);

    return Padding(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      child: isMobile
          ? Column(
              children: [
                SizedBox(
                  height: mobileLeftPanelHeight,
                  width: double.infinity,
                  child: const _PermissionsLeftPanel(),
                ),
                const SizedBox(height: 16),
                Expanded(child: _PermissionsRightPanel(isMobile: isMobile)),
              ],
            )
          : Row(
              children: [
                const SizedBox(
                  width: 320,
                  child: _PermissionsLeftPanel(),
                ),
                const SizedBox(width: 20),
                Expanded(child: _PermissionsRightPanel(isMobile: isMobile)),
              ],
            ),
    );
  }
}

class _PermissionsLeftPanel extends GetView<PeopleController> {
  const _PermissionsLeftPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _PermissionTypeButton(
                        label: 'Staff',
                        isActive:
                            controller.selectedPermissionType.value == 'staff',
                        onTap: () => controller.selectPermissionType('staff'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PermissionTypeButton(
                        label: 'Vendor',
                        isActive:
                            controller.selectedPermissionType.value == 'vendor',
                        onTap: () => controller.selectPermissionType('vendor'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isPermissionsLoading.value &&
                  controller.permissionSubjects.isEmpty) {
                return const _CenteredLoader(message: 'Loading users...');
              }
              if (controller.permissionSubjects.isEmpty) {
                return Obx(
                  () => _EmptyState(
                    icon: Icons.person_search_outlined,
                    title:
                        'No ${controller.selectedPermissionType.value} found',
                    description:
                        'There are no records available for permission management yet.',
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                itemCount: controller.permissionSubjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final subject = controller.permissionSubjects[index];
                  return Obx(() {
                    final isSelected =
                        controller.selectedPermissionSubjectId.value ==
                            subject.id;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            controller.selectPermissionSubject(subject.id),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.22)
                                  : const Color(0xFFF1F5F9),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFFEFF6FF),
                                child: Text(
                                  subject.avatarLabel,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.primary
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    if (subject.subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        subject.subtitle!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PermissionsRightPanel extends GetView<PeopleController> {
  const _PermissionsRightPanel({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() {
        final selectedId = controller.selectedPermissionSubjectId.value;
        if (selectedId == null) {
          return const _EmptyState(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Select a record',
            description:
                'Choose a staff member or vendor from the left side to manage permissions.',
          );
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isMobile ? 18 : 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assign Permissions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            'Control what this ${controller.selectedPermissionType.value} can see and do.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: controller.isPermissionSaving.value
                        ? null
                        : controller.savePermissions,
                    icon: controller.isPermissionSaving.value
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Expanded(
              child: Obx(() {
                if (controller.isPermissionsLoading.value &&
                    controller.currentPermissions.isEmpty) {
                  return const _CenteredLoader(
                    message: 'Loading permissions...',
                  );
                }
                if (controller.permissionModules.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.lock_outline_rounded,
                    title: 'No permission modules found',
                    description:
                        'Permission modules are not available from the API yet.',
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  itemCount: controller.permissionModules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final module = controller.permissionModules[index];
                    return _PermissionModuleCard(module: module);
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

class _PermissionModuleCard extends GetView<PeopleController> {
  const _PermissionModuleCard({required this.module});

  final PermissionModuleModel module;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        color: Colors.white,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        leading: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          module.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
          ),
        ),
        subtitle: Text(
          '${module.permissions.length} permission${module.permissions.length == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: module.permissions.map((permission) {
              return Obx(() {
                final isSelected =
                    controller.currentPermissions.contains(permission.code);
                return FilterChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        permission.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFF4B5563),
                        ),
                      ),
                      Text(
                        permission.code,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.75)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) =>
                      controller.togglePermission(permission.code),
                  showCheckmark: true,
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primary.withValues(alpha: 0.10),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.28)
                        : const Color(0xFFE5E7EB),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                );
              });
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _EventStaffTable extends StatelessWidget {
  const _EventStaffTable({
    required this.staffList,
    required this.onEdit,
    required this.onDelete,
    required this.onViewPayments,
  });

  final List<StaffModel> staffList;
  final ValueChanged<StaffModel> onEdit;
  final ValueChanged<StaffModel> onDelete;
  final ValueChanged<StaffModel> onViewPayments;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(34, 0, 34, 28),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1260),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
                child: const _TableHeaderRow(
                  columns: [
                    _TableColumn(label: '#', width: 90),
                    _TableColumn(label: 'Name', width: 430),
                    _TableColumn(label: 'Phone', width: 220),
                    _TableColumn(label: 'Role & Type', width: 260),
                    _TableColumn(label: 'Financials', width: 280),
                    _TableColumn(
                        label: 'Status', width: 170, alignCenter: true),
                    _TableColumn(
                        label: 'Actions', width: 190, alignCenter: true),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ...List.generate(
                staffList.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _EventStaffTableRow(
                    staff: staffList[index],
                    index: index,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onViewPayments: onViewPayments,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventStaffTableRow extends StatelessWidget {
  const _EventStaffTableRow({
    required this.staff,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onViewPayments,
  });

  final StaffModel staff;
  final int index;
  final ValueChanged<StaffModel> onEdit;
  final ValueChanged<StaffModel> onDelete;
  final ValueChanged<StaffModel> onViewPayments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5F7FB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _TableCell(
            width: 90,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _TableCell(
            width: 430,
            child: Row(
              children: [
                _EventStaffAvatar(label: _avatarLetter(staff.name)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    staff.name ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _TableCell(
            width: 220,
            child: Text(
              staff.mobile ?? '-',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _TableCell(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  staff.role ?? 'N/A',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _EventStaffMiniChip(label: staff.displayType.toUpperCase()),
                    if (staff.waiterTypeName != null)
                      _EventStaffMiniChip(
                        label: staff.waiterTypeName!.toUpperCase(),
                      ),
                    if (staff.agencyName != null)
                      _EventStaffMiniChip(
                        label: staff.agencyName!.toUpperCase(),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _TableCell(
            width: 280,
            child: _EventStaffFinancials(staff: staff),
          ),
          _TableCell(
            width: 170,
            alignCenter: true,
            child: _EventStaffStatusPill(isActive: staff.isActive),
          ),
          _TableCell(
            width: 190,
            alignCenter: true,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                if (staff.displayType.toLowerCase() == 'fixed')
                  _EventStaffActionIconButton(
                    icon: Icons.account_balance_wallet_outlined,
                    color: const Color(0xFF6B7280),
                    tooltip: 'Salary Payments',
                    onTap: () => onViewPayments(staff),
                  ),
                _EventStaffActionIconButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF9CA3AF),
                  tooltip: 'Edit Staff',
                  onTap: () => onEdit(staff),
                ),
                _EventStaffActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFFCA5A5),
                  tooltip: 'Delete Staff',
                  onTap: () => onDelete(staff),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventStaffMobileList extends StatelessWidget {
  const _EventStaffMobileList({
    required this.staffList,
    required this.onEdit,
    required this.onDelete,
    required this.onViewPayments,
  });

  final List<StaffModel> staffList;
  final ValueChanged<StaffModel> onEdit;
  final ValueChanged<StaffModel> onDelete;
  final ValueChanged<StaffModel> onViewPayments;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: staffList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final staff = staffList[index];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _EventStaffAvatar(label: _avatarLetter(staff.name)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.name ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          staff.mobile ?? '-',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                staff.role ?? 'N/A',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _EventStaffMiniChip(label: staff.displayType.toUpperCase()),
                  if (staff.waiterTypeName != null)
                    _EventStaffMiniChip(
                      label: staff.waiterTypeName!.toUpperCase(),
                    ),
                  if (staff.agencyName != null)
                    _EventStaffMiniChip(
                      label: staff.agencyName!.toUpperCase(),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _EventStaffFinancials(staff: staff),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _EventStaffStatusPill(isActive: staff.isActive),
                  if (staff.displayType.toLowerCase() == 'fixed')
                    _ActionTextButton(
                      label: 'Payments',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => onViewPayments(staff),
                    ),
                  _ActionTextButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onTap: () => onEdit(staff),
                  ),
                  _ActionTextButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    isDestructive: true,
                    onTap: () => onDelete(staff),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EventStaffPanelHeader extends StatelessWidget {
  const _EventStaffPanelHeader({
    required this.isMobile,
    required this.staffCount,
    required this.onAddStaff,
  });

  final bool isMobile;
  final int staffCount;
  final VoidCallback onAddStaff;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isMobile ? 18.0 : 34.0;
    final content = Row(
      children: [
        Container(
          height: isMobile ? 58 : 66,
          width: isMobile ? 58 : 66,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.groups_2_outlined,
            color: AppColors.primary,
            size: isMobile ? 28 : 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Staff',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$staffCount staff member${staffCount == 1 ? '' : 's'} registered',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actionButton = ElevatedButton.icon(
      onPressed: onAddStaff,
      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
      label: const Text('Add Staff'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isMobile ? 18 : 28,
        horizontalPadding,
        isMobile ? 18 : 30,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 16),
                actionButton,
              ],
            )
          : Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 16),
                actionButton,
              ],
            ),
    );
  }
}

class _EventStaffAvatar extends StatelessWidget {
  const _EventStaffAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.72),
        border: Border.all(color: const Color(0xFFE0ECFA), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _EventStaffMiniChip extends StatelessWidget {
  const _EventStaffMiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _EventStaffFinancials extends StatelessWidget {
  const _EventStaffFinancials({required this.staff});

  final StaffModel staff;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if ((staff.perPersonRate ?? 0) > 0) {
      items.add(
        _EventStaffFinancialBadge(
          label: 'Per Day',
          value: '₹${staff.perPersonRate!.toStringAsFixed(2)}',
        ),
      );
    }
    if ((staff.fixedSalary ?? 0) > 0) {
      items.add(
        _EventStaffFinancialBadge(
          label: 'Fixed',
          value: '₹${staff.fixedSalary!.toStringAsFixed(2)} /mo',
          isTinted: true,
        ),
      );
    }
    if ((staff.contractRate ?? 0) > 0) {
      items.add(
        _EventStaffFinancialBadge(
          label: 'Contract',
          value: '₹${staff.contractRate!.toStringAsFixed(2)}',
          isTinted: true,
        ),
      );
    }
    if (items.isEmpty && (staff.salary ?? 0) > 0) {
      items.add(
        _EventStaffFinancialBadge(
          label: 'Salary',
          value: '₹${staff.salary!.toStringAsFixed(2)}',
        ),
      );
    }

    if (items.isEmpty) {
      return const Text(
        'No financials',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF9CA3AF),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items,
    );
  }
}

class _EventStaffFinancialBadge extends StatelessWidget {
  const _EventStaffFinancialBadge({
    required this.label,
    required this.value,
    this.isTinted = false,
    this.suffix,
  });

  final String label;
  final String value;
  final bool isTinted;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTinted
            ? AppColors.primary.withValues(alpha: 0.08)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTinted
              ? AppColors.primary.withValues(alpha: 0.12)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
          ),
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isTinted ? AppColors.primary : const Color(0xFF6B7280),
              ),
            ),
            TextSpan(
              text: ' $value',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isTinted ? AppColors.primary : const Color(0xFF1F2937),
              ),
            ),
            if (suffix != null)
              TextSpan(
                text: suffix,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isTinted
                      ? AppColors.primary.withValues(alpha: 0.72)
                      : const Color(0xFF9CA3AF),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventStaffStatusPill extends StatelessWidget {
  const _EventStaffStatusPill({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFECACA),
        ),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: isActive ? AppColors.primary : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}

class _EventStaffActionIconButton extends StatelessWidget {
  const _EventStaffActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          width: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _FixedStaffPaymentSummaryDialog extends StatelessWidget {
  const _FixedStaffPaymentSummaryDialog({required this.summary});

  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final salaryPayments = _asList(summary['salary_payments']);
    final eventPayments = _asList(summary['event_payments']);
    final fixedSalary = _asDouble(summary['fixed_salary']);
    final pendingMonths = _asDouble(summary['pending_months']);
    final pendingSalary = fixedSalary * pendingMonths;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary['staff_name']?.toString() ?? 'Payment Summary',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary['role_name'] ?? summary['staff_type'] ?? 'Fixed Staff'} payment details',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _SummaryMetricCard(
                label: 'Monthly Salary',
                value: _currency(fixedSalary),
                icon: Icons.payments_outlined,
              ),
              _SummaryMetricCard(
                label: 'Total Salary Paid',
                value: _currency(_asDouble(summary['total_salary_paid'])),
                icon: Icons.check_circle_outline_rounded,
              ),
              _SummaryMetricCard(
                label: 'Salary Pending',
                value: _currency(pendingSalary),
                icon: Icons.calendar_month_outlined,
                accent: pendingSalary > 0
                    ? const Color(0xFFEF4444)
                    : AppColors.primary,
              ),
              _SummaryMetricCard(
                label: 'Pending Withdrawals',
                value:
                    _currency(_asDouble(summary['total_pending_withdrawals'])),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SummaryTableCard(
            title: 'Salary Payment Records',
            emptyLabel: 'No salary payment records found.',
            columns: const ['Period', 'Total', 'Paid', 'Pending', 'Status'],
            rows: salaryPayments.map((payment) {
              final item = Map<String, dynamic>.from(payment);
              return [
                '${item['start_date'] ?? '-'} to ${item['end_date'] ?? '-'}',
                _currency(_asDouble(item['total_amount'])),
                _currency(_asDouble(item['paid_amount'])),
                _currency(_asDouble(item['remaining_amount'])),
                item['payment_status']?.toString() ?? '-',
              ];
            }).toList(growable: false),
          ),
          const SizedBox(height: 18),
          _SummaryTableCard(
            title: 'Event Payment Records',
            emptyLabel: 'No event payment records found.',
            columns: const ['Event', 'Total', 'Paid', 'Pending'],
            rows: eventPayments.map((payment) {
              final item = Map<String, dynamic>.from(payment);
              return [
                '${item['session_name'] ?? '-'}\n${item['session_date'] ?? ''}',
                _currency(_asDouble(item['total_amount'])),
                _currency(_asDouble(item['paid_amount'])),
                _currency(_asDouble(item['remaining_amount'])),
              ];
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final activeColor = accent ?? AppColors.primary;

    return Container(
      width: 215,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: activeColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTableCard extends StatelessWidget {
  const _SummaryTableCard({
    required this.title,
    required this.emptyLabel,
    required this.columns,
    required this.rows,
  });

  final String title;
  final String emptyLabel;
  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                emptyLabel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 58,
                dataRowMaxHeight: 78,
                columnSpacing: 24,
                columns: columns
                    .map(
                      (column) => DataColumn(
                        label: Text(
                          column.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
                rows: rows
                    .map(
                      (row) => DataRow(
                        cells: row
                            .map(
                              (cell) => DataCell(
                                Text(
                                  cell,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }
}

class _VendorTable extends GetView<PeopleController> {
  const _VendorTable({required this.vendors});

  final List<VendorModel> vendors;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1200),
          child: Column(
            children: [
              const _TableHeaderRow(
                columns: [
                  _TableColumn(label: '#', width: 90),
                  _TableColumn(label: 'Vendor Name', width: 260),
                  _TableColumn(label: 'Mobile', width: 170),
                  _TableColumn(label: 'Address', width: 240),
                  _TableColumn(label: 'Categories', width: 330),
                  _TableColumn(label: 'Status', width: 150, alignCenter: true),
                  _TableColumn(label: 'Actions', width: 160, alignCenter: true),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                vendors.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _VendorRow(vendor: vendors[index], index: index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorRow extends GetView<PeopleController> {
  const _VendorRow({
    required this.vendor,
    required this.index,
  });

  final VendorModel vendor;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _TableCell(
            width: 90,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _TableCell(
            width: 260,
            child: Text(
              vendor.name ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          _TableCell(
            width: 170,
            child: Text(
              vendor.mobile ?? '-',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _TableCell(
            width: 240,
            child: Text(
              vendor.address ?? '-',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _TableCell(
            width: 330,
            child: vendor.vendorCategories.isEmpty
                ? const Text(
                    'No categories',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: vendor.vendorCategories.map((category) {
                      final priceText = category.price == null
                          ? ''
                          : '  ₹${category.price!.toStringAsFixed(0)}';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          '${category.categoryName}$priceText',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
          ),
          _TableCell(
            width: 150,
            alignCenter: true,
            child: _StatusPill(
              label: vendor.isActive ? 'ACTIVE' : 'INACTIVE',
              isActive: vendor.isActive,
            ),
          ),
          _TableCell(
            width: 160,
            alignCenter: true,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                _ActionIconButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF6B7280),
                  tooltip: 'Edit Vendor',
                  onTap: () => controller.showComingSoon(
                    'Edit vendor form is not migrated in the app yet.',
                  ),
                ),
                _ActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFF87171),
                  tooltip: 'Delete Vendor',
                  onTap: () {
                    if (vendor.id != null) {
                      controller.deleteVendor(vendor.id!);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorMobileList extends GetView<PeopleController> {
  const _VendorMobileList({required this.vendors});

  final List<VendorModel> vendors;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: vendors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vendor.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  _StatusPill(
                    label: vendor.isActive ? 'ACTIVE' : 'INACTIVE',
                    isActive: vendor.isActive,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                vendor.mobile ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              if ((vendor.address ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  vendor.address!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (vendor.vendorCategories.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: vendor.vendorCategories.map((category) {
                    return _MiniTag(
                      label: category.price == null
                          ? category.categoryName
                          : '${category.categoryName}  ₹${category.price!.toStringAsFixed(0)}',
                    );
                  }).toList(growable: false),
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionTextButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onTap: () => controller.showComingSoon(
                      'Edit vendor form is not migrated in the app yet.',
                    ),
                  ),
                  _ActionTextButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    isDestructive: true,
                    onTap: () {
                      if (vendor.id != null) {
                        controller.deleteVendor(vendor.id!);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaiterTypesTable extends GetView<PeopleController> {
  const _WaiterTypesTable({
    required this.waiterTypes,
    required this.onEdit,
  });

  final List<WaiterTypeModel> waiterTypes;
  final ValueChanged<WaiterTypeModel> onEdit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1000),
          child: Column(
            children: [
              const _TableHeaderRow(
                columns: [
                  _TableColumn(label: '#', width: 90),
                  _TableColumn(label: 'Name', width: 240),
                  _TableColumn(label: 'Description', width: 360),
                  _TableColumn(label: 'Rate', width: 180),
                  _TableColumn(label: 'Status', width: 150, alignCenter: true),
                  _TableColumn(label: 'Actions', width: 160, alignCenter: true),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                waiterTypes.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _WaiterTypeRow(
                    waiterType: waiterTypes[index],
                    index: index,
                    onEdit: onEdit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaiterTypeRow extends GetView<PeopleController> {
  const _WaiterTypeRow({
    required this.waiterType,
    required this.index,
    required this.onEdit,
  });

  final WaiterTypeModel waiterType;
  final int index;
  final ValueChanged<WaiterTypeModel> onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _TableCell(
            width: 90,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _TableCell(
            width: 240,
            child: Text(
              waiterType.name ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          _TableCell(
            width: 360,
            child: Text(
              waiterType.description ?? 'No description provided',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _TableCell(
            width: 180,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Text(
                '₹${(waiterType.rate ?? 0).toStringAsFixed(2)} / person',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          _TableCell(
            width: 150,
            alignCenter: true,
            child: _StatusPill(
              label: waiterType.isActive ? 'ACTIVE' : 'INACTIVE',
              isActive: waiterType.isActive,
            ),
          ),
          _TableCell(
            width: 160,
            alignCenter: true,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                _ActionIconButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF6B7280),
                  tooltip: 'Edit Waiter Type',
                  onTap: () => onEdit(waiterType),
                ),
                _ActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFF87171),
                  tooltip: 'Delete Waiter Type',
                  onTap: () {
                    if (waiterType.id != null) {
                      controller.deleteWaiterType(waiterType.id!);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaiterTypesMobileList extends GetView<PeopleController> {
  const _WaiterTypesMobileList({
    required this.waiterTypes,
    required this.onEdit,
  });

  final List<WaiterTypeModel> waiterTypes;
  final ValueChanged<WaiterTypeModel> onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: waiterTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final waiterType = waiterTypes[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      waiterType.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  _StatusPill(
                    label: waiterType.isActive ? 'ACTIVE' : 'INACTIVE',
                    isActive: waiterType.isActive,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                waiterType.description ?? 'No description provided',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              _MiniTag(
                label: '₹${(waiterType.rate ?? 0).toStringAsFixed(2)} / person',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionTextButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onTap: () => onEdit(waiterType),
                  ),
                  _ActionTextButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    isDestructive: true,
                    onTap: () {
                      if (waiterType.id != null) {
                        controller.deleteWaiterType(waiterType.id!);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitleBuilder,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String Function() subtitleBuilder;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.width < 900;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 24,
        isMobile ? 18 : 24,
        isMobile ? 18 : 24,
        18,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleBuilder(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon, size: 18),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.columns});

  final List<_TableColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: columns
          .map(
            (column) => _TableCell(
              width: column.width,
              alignCenter: column.alignCenter,
              child: Text(
                column.label.toUpperCase(),
                textAlign:
                    column.alignCenter ? TextAlign.center : TextAlign.left,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.width,
    required this.child,
    this.alignCenter = false,
  });

  final double width;
  final Widget child;
  final bool alignCenter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      alignment: alignCenter ? Alignment.center : Alignment.centerLeft,
      child: child,
    );
  }
}

class _TableColumn {
  const _TableColumn({
    required this.label,
    required this.width,
    this.alignCenter = false,
  });

  final String label;
  final double width;
  final bool alignCenter;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final background = isActive
        ? AppColors.primary.withValues(alpha: 0.08)
        : const Color(0xFFFEF2F2);
    final border = isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFECACA);
    final textColor = isActive ? AppColors.primary : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: textColor,
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _ActionTextButton extends StatelessWidget {
  const _ActionTextButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFDC2626) : AppColors.primary;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isDestructive
              ? const Color(0xFFFECACA)
              : AppColors.primary.withValues(alpha: 0.18),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

InputDecoration _dialogInputDecoration({required String hintText}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  );
}

class _PermissionTypeButton extends StatelessWidget {
  const _PermissionTypeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isActive ? AppColors.primary : Colors.transparent,
        foregroundColor: isActive ? Colors.white : const Color(0xFF6B7280),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(label),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: _dialogInputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
  return const [];
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}') ?? 0;
}

String _currency(double value) {
  return '₹${value.toStringAsFixed(2)}';
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 460),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 34, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleTabData {
  const _PeopleTabData({
    required this.section,
    required this.label,
    required this.icon,
  });

  final PeopleSection section;
  final String label;
  final IconData icon;
}

String _avatarLetter(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return '?';
  }
  return normalized[0].toUpperCase();
}
