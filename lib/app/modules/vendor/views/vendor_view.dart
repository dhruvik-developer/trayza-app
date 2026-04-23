import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading.dart';
import '../../layout/views/layout_view.dart';
import '../controllers/vendor_controller.dart';

class VendorView extends GetView<VendorController> {
  const VendorView({Key? key}) : super(key: key);

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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Expanded(child: LoaderWebView());
                  }
                  if (controller.vendors.isEmpty) {
                    return _buildEmptyState();
                  }
                  return Expanded(
                    child: _buildVendorGrid(context),
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
              decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.local_shipping_rounded,
                  color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Vendors",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Obx(() => Text("${controller.vendors.length} active suppliers",
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary))),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_business_rounded, size: 18),
          label: const Text("New Vendor"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisExtent: 180,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.vendors.length,
      itemBuilder: (context, index) {
        final vendor = controller.vendors[index];
        return _buildVendorCard(vendor);
      },
    );
  }

  Widget _buildVendorCard(vendor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor.name ?? "Unknown Vendor",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary)),
                    Text(vendor.category ?? "General Supplier",
                        style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.grey, size: 20),
                  onPressed: () => controller.deleteVendor(vendor.id!)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(vendor.contactPerson ?? "N/A",
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(vendor.mobile ?? "-",
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(vendor.address ?? "No Address",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis)),
              const Icon(Icons.edit_note_rounded, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_shipping_outlined,
              size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text("No vendors listed",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
              onPressed: () {}, child: const Text("Register Vendor")),
        ],
      ),
    );
  }
}
