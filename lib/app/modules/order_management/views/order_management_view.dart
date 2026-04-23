import 'package:flutter/material.dart';

import '../../all_order/views/all_order_view.dart';
import '../../event_summary/views/event_summary_view.dart';
import '../../invoice/views/invoice_view.dart';
import '../../quotation/views/quotation_view.dart';
import '../widgets/order_management_page_scaffold.dart';
import '../widgets/order_management_tabs.dart';

class OrderManagementView extends StatefulWidget {
  const OrderManagementView({
    super.key,
    this.initialSection = OrderManagementSection.quotation,
  });

  final OrderManagementSection initialSection;

  @override
  State<OrderManagementView> createState() => _OrderManagementViewState();
}

class _OrderManagementViewState extends State<OrderManagementView> {
  late OrderManagementSection _currentSection;
  late final Set<OrderManagementSection> _loadedSections;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection;
    _loadedSections = {widget.initialSection};
  }

  void _setSection(OrderManagementSection section) {
    if (_currentSection == section) return;

    setState(() {
      _currentSection = section;
      _loadedSections.add(section);
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = _sectionConfig(_currentSection);

    return OrderManagementPageScaffold(
      activeIndex: 2,
      currentSection: _currentSection,
      onSectionSelected: _setSection,
      title: config.title,
      subtitle: config.subtitle,
      icon: config.icon,
      child: IndexedStack(
        index: _currentSection.index,
        children: [
          _loadedSections.contains(OrderManagementSection.quotation)
              ? const QuotationView(embedInShell: true)
              : const SizedBox.shrink(),
          _loadedSections.contains(OrderManagementSection.allOrder)
              ? const AllOrderView(embedInShell: true)
              : const SizedBox.shrink(),
          _loadedSections.contains(OrderManagementSection.invoice)
              ? const InvoiceView(embedInShell: true)
              : const SizedBox.shrink(),
          _loadedSections.contains(OrderManagementSection.eventSummary)
              ? const EventSummaryView(embedInShell: true)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  _SectionConfig _sectionConfig(OrderManagementSection section) {
    switch (section) {
      case OrderManagementSection.quotation:
        return const _SectionConfig(
          title: 'Quotation',
          subtitle: 'Generate and manage client quotes',
          icon: Icons.description_outlined,
        );
      case OrderManagementSection.allOrder:
        return const _SectionConfig(
          title: 'All Orders',
          subtitle: 'Manage confirmed event bookings and final settlements',
          icon: Icons.assignment_outlined,
        );
      case OrderManagementSection.invoice:
        return const _SectionConfig(
          title: 'Invoice',
          subtitle: 'Track billing, settlements, and client-ready bill sharing',
          icon: Icons.receipt_long_outlined,
        );
      case OrderManagementSection.eventSummary:
        return const _SectionConfig(
          title: 'Event Summary',
          subtitle:
              'Monitor staffing totals, payment status, and assignment-level dues',
          icon: Icons.bar_chart_rounded,
        );
    }
  }
}

class _SectionConfig {
  const _SectionConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
