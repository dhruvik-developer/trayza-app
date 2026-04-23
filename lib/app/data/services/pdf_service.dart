import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:get/get.dart';

import '../../modules/order_management/utils/order_management_utils.dart';
import '../models/invoice_model.dart';
import '../models/order_model.dart';
import 'business_profile_service.dart';

class PdfService extends GetxService {
  static PdfService get to => Get.find();

  Future<void> generateBookingPdf(Map<String, dynamic> data) async {
    final pdf = _buildDocument(
      title: 'Event Booking Summary',
      subtitle: 'Quotation preview',
      content: [
        _buildInfoCard(
          <String, String>{
            'Client': data['name']?.toString() ?? '—',
            'Mobile': data['mobile_no']?.toString() ?? '—',
            'Event Date': data['date']?.toString() ?? '—',
            'Total Amount': '₹${data['grandTotalAmount'] ?? '0'}',
          },
        ),
      ],
    );

    await _previewPdf(pdf);
  }

  Future<void> generateOrderPdf(
    OrderModel order, {
    required String title,
    required String subtitle,
  }) async {
    final pdf = _buildOrderDocument(
      order,
      title: title,
      subtitle: subtitle,
    );

    await _previewPdf(pdf);
  }

  Future<void> shareOrderPdf(
    OrderModel order, {
    required String title,
    required String subtitle,
  }) async {
    final pdf = _buildOrderDocument(
      order,
      title: title,
      subtitle: subtitle,
    );

    await _sharePdf(
      pdf,
      _buildFileName(order.name, 'order-${order.id}'),
    );
  }

  Future<void> generateInvoicePdf(
    InvoiceModel invoice, {
    required String title,
    required String subtitle,
  }) async {
    final pdf = _buildInvoiceDocument(
      invoice,
      title: title,
      subtitle: subtitle,
      includeBillStyleSummary: false,
    );

    await _previewPdf(pdf);
  }

  Future<void> generateBillPdf(
    InvoiceModel invoice, {
    required String title,
    required String subtitle,
  }) async {
    final pdf = _buildInvoiceDocument(
      invoice,
      title: title,
      subtitle: subtitle,
      includeBillStyleSummary: true,
    );

    await _previewPdf(pdf);
  }

  Future<void> shareBillPdf(
    InvoiceModel invoice, {
    required String title,
    required String subtitle,
  }) async {
    final pdf = _buildInvoiceDocument(
      invoice,
      title: title,
      subtitle: subtitle,
      includeBillStyleSummary: true,
    );

    await _sharePdf(
      pdf,
      _buildFileName(invoice.booking.name, 'bill-${invoice.billNo}'),
    );
  }

  pw.Document _buildOrderDocument(
    OrderModel order, {
    required String title,
    required String subtitle,
  }) {
    return _buildDocument(
      title: title,
      subtitle: subtitle,
      content: [
        _buildInfoCard(
          <String, String>{
            'Customer': order.name,
            'Mobile': order.mobileNo?.isNotEmpty == true ? order.mobileNo! : '—',
            'Reference': order.reference?.isNotEmpty == true ? order.reference! : '—',
            'Event Dates': order.eventDateSummary,
            'Status': order.status?.isNotEmpty == true ? order.status! : '—',
            'Address': order.eventAddress?.isNotEmpty == true ? order.eventAddress! : '—',
          },
        ),
        pw.SizedBox(height: 18),
        _buildSectionTitle('Session Summary'),
        ...order.effectiveSessions.asMap().entries.map(
              (entry) => _buildSessionCard(
                index: entry.key + 1,
                session: entry.value,
              ),
            ),
        pw.SizedBox(height: 18),
        _buildTotalsCard(
          <String, String>{
            'Total Estimated Persons': order.totalEstimatedPersons.toString(),
            'Order Amount': OrderManagementUtils.formatCurrency(order.totalAmount),
            'Advance Received': OrderManagementUtils.formatCurrency(order.advanceAmount),
            'Pending Amount': OrderManagementUtils.formatCurrency(order.remainingAmount),
          },
        ),
      ],
    );
  }

  pw.Document _buildInvoiceDocument(
    InvoiceModel invoice, {
    required String title,
    required String subtitle,
    required bool includeBillStyleSummary,
  }) {
    final order = invoice.booking;
    final receivedAmount = includeBillStyleSummary
        ? invoice.advanceAmount + invoice.transactionAmount + invoice.settlementAmount
        : invoice.advanceAmount;

    return _buildDocument(
      title: title,
      subtitle: subtitle,
      content: [
        _buildInfoCard(
          <String, String>{
            'Bill No': invoice.billNo.isEmpty ? '—' : invoice.billNo,
            'Customer': order.name,
            'Mobile': order.mobileNo?.isNotEmpty == true ? order.mobileNo! : '—',
            'Reference': order.reference?.isNotEmpty == true ? order.reference! : '—',
            'Event Dates': invoice.eventDateSummary,
            'Payment Mode': invoice.paymentMode.isNotEmpty ? invoice.paymentMode : '—',
            'Payment Status': invoice.paymentStatus.isNotEmpty ? invoice.paymentStatus : '—',
          },
        ),
        pw.SizedBox(height: 18),
        _buildSectionTitle('Order Sessions'),
        ...order.effectiveSessions.asMap().entries.map(
              (entry) => _buildSessionCard(
                index: entry.key + 1,
                session: entry.value,
              ),
            ),
        pw.SizedBox(height: 18),
        _buildTotalsCard(
          <String, String>{
            'Total Amount': OrderManagementUtils.formatCurrency(invoice.totalAmount),
            includeBillStyleSummary ? 'Total Received' : 'Advance Amount':
                OrderManagementUtils.formatCurrency(receivedAmount),
            'Transaction Amount':
                OrderManagementUtils.formatCurrency(invoice.transactionAmount),
            'Settlement Amount':
                OrderManagementUtils.formatCurrency(invoice.settlementAmount),
            'Pending Amount':
                OrderManagementUtils.formatCurrency(invoice.displayPendingAmount),
          },
        ),
      ],
    );
  }

  pw.Document _buildDocument({
    required String title,
    required String subtitle,
    required List<pw.Widget> content,
  }) {
    final pdf = pw.Document();
    final businessName = Get.isRegistered<BusinessProfileService>()
        ? (BusinessProfileService.to.catersName ?? 'Trayza Admin')
        : 'Trayza Admin';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 14),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  businessName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          ...content,
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Generated on ${OrderManagementUtils.formatDateValue(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ),
    );

    return pdf;
  }

  pw.Widget _buildInfoCard(Map<String, String> values) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8F7FB'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: values.entries
            .map(
              (entry) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 118,
                      child: pw.Text(
                        entry.key,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(entry.value),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  pw.Widget _buildSectionTitle(String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildSessionCard({
    required int index,
    required OrderSessionModel session,
  }) {
    final extras = session.extraService
        .map(
          (item) => '${item['extra'] ?? item['name'] ?? 'Extra'}: '
              '${OrderManagementUtils.formatCurrency(_toDouble(item['amount']), withSymbol: true)}',
        )
        .toList();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Session $index',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Date: ${OrderManagementUtils.formatDisplayDate(session.eventDate)}',
          ),
          pw.Text('Time: ${session.eventTime ?? '—'}'),
          pw.Text('Estimated Persons: ${session.estimatedPersons}'),
          pw.Text(
            'Per Dish Amount: ${OrderManagementUtils.formatCurrency(session.perDishAmount)}',
          ),
          if (session.extraServiceAmount > 0)
            pw.Text(
              'Extra Service Amount: ${OrderManagementUtils.formatCurrency(session.extraServiceAmount)}',
            ),
          if (session.waiterServiceAmount > 0)
            pw.Text(
              'Waiter Service Amount: ${OrderManagementUtils.formatCurrency(session.waiterServiceAmount)}',
            ),
          if (extras.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...extras.map((extra) => pw.Text(extra)),
          ],
          pw.SizedBox(height: 8),
          pw.Text(
            'Session Total: ${OrderManagementUtils.formatCurrency(session.totalAmount)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotalsCard(Map<String, String> values) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF8E8'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: values.entries
            .map(
              (entry) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        entry.key,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Text(entry.value),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _previewPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _sharePdf(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  String _buildFileName(String source, String fallback) {
    final sanitized = source
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    final base = sanitized.isEmpty ? fallback : sanitized;
    return '$base.pdf';
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
