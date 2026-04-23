import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OrderManagementDateRangeField extends StatelessWidget {
  const OrderManagementDateRangeField({
    super.key,
    required this.label,
    required this.onTap,
    required this.hasValue,
    this.onClear,
  });

  final String label;
  final VoidCallback onTap;
  final bool hasValue;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD9E2EC),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 22,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: hasValue
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (hasValue && onClear != null) ...[
                const SizedBox(width: 14),
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
