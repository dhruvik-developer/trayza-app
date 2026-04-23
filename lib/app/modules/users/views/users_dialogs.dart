import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../controllers/users_controller.dart';

class UsersDialogs {
  static Future<void> showAddUserDialog(
    BuildContext context,
    UsersController controller,
  ) async {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _UsersDialogHeader(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Add New User',
                  subtitle: 'Create a user exactly like the website flow',
                ),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _UsersFieldLabel('User Name'),
                      const SizedBox(height: 8),
                      _UsersInput(
                        controller: usernameController,
                        hintText: 'Enter user name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'User name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const _UsersFieldLabel('Email'),
                      const SizedBox(height: 8),
                      _UsersInput(
                        controller: emailController,
                        hintText: 'Enter email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final normalized = value?.trim() ?? '';
                          if (normalized.isEmpty) return null;
                          final emailRegex =
                              RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                          if (!emailRegex.hasMatch(normalized)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Optional',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _UsersFieldLabel('Password'),
                      const SizedBox(height: 8),
                      _UsersInput(
                        controller: passwordController,
                        hintText: 'Enter password',
                        obscureText: true,
                        validator: (value) {
                          final normalized = value?.trim() ?? '';
                          if (normalized.isEmpty) {
                            return 'Password is required';
                          }
                          if (normalized.length < 4) {
                            return 'Password must be at least 4 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _UsersDialogActions(
                  primaryLabel: 'Save',
                  onPrimaryTap: () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    final didSave = await controller.addUser(
                      username: usernameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                    );

                    if (didSave) {
                      Get.back<void>();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showChangePasswordDialog(
    BuildContext context,
    UsersController controller,
    UserModel user,
  ) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _UsersDialogHeader(
                  icon: Icons.lock_reset_rounded,
                  title: 'Change User Password',
                  subtitle: 'Website edit action updates password only',
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? '-',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _UsersFieldLabel('New Password'),
                      const SizedBox(height: 8),
                      _UsersInput(
                        controller: passwordController,
                        hintText: 'Enter new password',
                        obscureText: true,
                        validator: (value) {
                          final normalized = value?.trim() ?? '';
                          if (normalized.isEmpty) {
                            return 'Password is required';
                          }
                          if (normalized.length < 4) {
                            return 'Password must be at least 4 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _UsersDialogActions(
                  primaryLabel: 'Update User',
                  onPrimaryTap: () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    final userId = user.id;
                    if (userId == null) {
                      Get.snackbar('Error', 'This user cannot be updated.');
                      return;
                    }

                    final didSave = await controller.updatePassword(
                      userId: userId,
                      password: passwordController.text,
                    );

                    if (didSave) {
                      Get.back<void>();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showDeleteConfirmation(
    BuildContext context,
    UsersController controller,
    UserModel user,
  ) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete User'),
        content: Text(
          'Delete ${user.username} permanently?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final userId = user.id;
              if (userId == null) {
                Get.snackbar('Error', 'This user cannot be deleted.');
                return;
              }

              final didDelete = await controller.deleteUser(userId);
              if (didDelete) {
                Get.back<void>();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _UsersDialogHeader extends StatelessWidget {
  const _UsersDialogHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.back<void>(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _UsersFieldLabel extends StatelessWidget {
  const _UsersFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _UsersInput extends StatelessWidget {
  const _UsersInput({
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _UsersDialogActions extends StatelessWidget {
  const _UsersDialogActions({
    required this.primaryLabel,
    required this.onPrimaryTap,
  });

  final String primaryLabel;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: onPrimaryTap,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          child: Text(primaryLabel),
        ),
      ],
    );
  }
}
