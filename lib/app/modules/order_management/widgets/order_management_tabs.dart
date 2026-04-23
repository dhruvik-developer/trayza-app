import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum OrderManagementSection {
  quotation,
  allOrder,
  invoice,
  eventSummary,
}

class OrderManagementTabs extends StatelessWidget {
  const OrderManagementTabs({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
  });

  final OrderManagementSection currentSection;
  final ValueChanged<OrderManagementSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (
        label: 'Quotation',
        icon: Icons.description_outlined,
        section: OrderManagementSection.quotation,
      ),
      (
        label: 'All Order',
        icon: Icons.assignment_outlined,
        section: OrderManagementSection.allOrder,
      ),
      (
        label: 'Invoice',
        icon: Icons.receipt_long_outlined,
        section: OrderManagementSection.invoice,
      ),
      (
        label: 'Event Summary',
        icon: Icons.bar_chart_rounded,
        section: OrderManagementSection.eventSummary,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isActive = tab.section == currentSection;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: isActive ? null : () => onSectionSelected(tab.section),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.82),
                            ],
                          )
                        : null,
                    color: isActive ? null : Colors.transparent,
                    border: Border.all(
                      color: isActive ? Colors.transparent : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.16)
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          tab.icon,
                          size: 18,
                          color: isActive ? Colors.white : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              isActive ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
