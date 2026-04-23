import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../controllers/users_controller.dart';
// import 'users_dialogs.dart';
import '../../layout/views/layout_view.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.width < 800;

    return LayoutView(
      headerTitle: 'Users',
      activeIndex: -1,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UsersPageHeader(isMobile: isMobile),
                const SizedBox(height: 24),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return _UsersTable(
                      users: controller.users,
                      // onEdit: (user) => UsersDialogs.showChangePasswordDialog(
                      //   context,
                      //   controller,
                      //   user,
                      // ),
                      // onDelete: (user) => UsersDialogs.showDeleteConfirmation(
                      //   context,
                      //   controller,
                      //   user,
                      // ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UsersPageHeader extends GetView<UsersController> {
  const _UsersPageHeader({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.people_alt_outlined,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Users',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF24324B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${controller.users.length} user${controller.users.length == 1 ? '' : 's'} registered',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Wrap(
        //   spacing: 14,
        //   runSpacing: 12,
        //   children: [
        //     ElevatedButton.icon(
        //       onPressed: () =>
        //           UsersDialogs.showAddUserDialog(context, controller),
        //       icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
        //       label: const Text('Add User'),
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: AppColors.primary,
        //         foregroundColor: Colors.white,
        //         padding:
        //             const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(16),
        //         ),
        //         textStyle: const TextStyle(
        //           fontSize: 15,
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //     ),
        //     OutlinedButton.icon(
        //       onPressed: controller.showRulesMessage,
        //       icon: Icon(
        //         Icons.menu_book_outlined,
        //         size: 18,
        //         color: AppColors.primary,
        //       ),
        //       label: Text(
        //         'Add Rule',
        //         style: TextStyle(
        //           color: AppColors.primary,
        //           fontSize: 15,
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //       style: OutlinedButton.styleFrom(
        //         side: BorderSide(color: AppColors.primary, width: 1.4),
        //         padding:
        //             const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(16),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class _UsersTable extends StatefulWidget {
  const _UsersTable({
    required this.users,
    // required this.onEdit,
    // required this.onDelete,
  });

  final List<UserModel> users;
  // final ValueChanged<UserModel> onEdit;
  // final ValueChanged<UserModel> onDelete;

  @override
  State<_UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<_UsersTable> {
  late final ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: context.width < 900 ? 720 : context.width - 96,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(90),
                1: FlexColumnWidth(2.2),
                2: FlexColumnWidth(2.3),
              },
              border: TableBorder.all(color: const Color(0xFFD1D5DB)),
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFF3F4F6)),
                  children: [
                    _HeaderCell('#', textAlign: TextAlign.left),
                    _HeaderCell('User Name', textAlign: TextAlign.left),
                    _HeaderCell('Email', textAlign: TextAlign.left),
                    // _HeaderCell('Actions', textAlign: TextAlign.center),
                  ],
                ),
                if (widget.users.isEmpty)
                  const TableRow(
                    children: [
                      _EmptyUsersCell(),
                      SizedBox.shrink(),
                      SizedBox.shrink(),
                    ],
                  )
                else
                  ...List.generate(
                    widget.users.length,
                    (index) => TableRow(
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? Colors.white
                            : const Color(0xFFFCFCFD),
                      ),
                      children: [
                        _BodyCell('${index + 1}'),
                        _BodyCell(widget.users[index].username.isEmpty
                            ? 'N/A'
                            : widget.users[index].username),
                        _BodyCell(widget.users[index].email ?? '-'),
                        // _ActionsCell(
                        //   user: widget.users[index],
                        //   onEdit: widget.onEdit,
                        //   onDelete: widget.onDelete,
                        // ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {required this.textAlign});

  final String label;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Text(
        label,
        textAlign: textAlign,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// class _ActionsCell extends StatelessWidget {
//   const _ActionsCell({
//     required this.user,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   final UserModel user;
//   final ValueChanged<UserModel> onEdit;
//   final ValueChanged<UserModel> onDelete;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             tooltip: 'Edit Password',
//             onPressed: user.id == null ? null : () => onEdit(user),
//             icon: const Icon(
//               Icons.edit_outlined,
//               color: Color(0xFF9CA3AF),
//               size: 20,
//             ),
//           ),
//           IconButton(
//             tooltip: 'Delete User',
//             onPressed: user.id == null ? null : () => onDelete(user),
//             icon: const Icon(
//               Icons.delete,
//               color: Color(0xFFEF4444),
//               size: 22,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _EmptyUsersCell extends StatelessWidget {
  const _EmptyUsersCell();

  @override
  Widget build(BuildContext context) {
    return const TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 28),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B), size: 28),
              SizedBox(width: 10),
              Text(
                'No Users Available!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
