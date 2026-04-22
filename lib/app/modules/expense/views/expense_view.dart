import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trayza_app/app/modules/expense/controllers/expense_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/views/layout_view.dart';
import 'package:intl/intl.dart';

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = context.width < 900;

    return LayoutView(
      activeIndex: 7,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isMobile),
                const SizedBox(height: 24),
                _buildSummaryCard(),
                const SizedBox(height: 20),
                _buildCategoryFilters(),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (controller.filteredExpenses.isEmpty) {
                    return _buildEmptyState();
                  }

                  return isMobile ? _buildMobileList() : _buildDataTable();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTitle(),
              const SizedBox(height: 16),
              _buildHeaderActions(context),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderTitle(),
              _buildHeaderActions(context),
            ],
          );
  }

  Widget _buildHeaderTitle() {
    return Obx(() => Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF4EFFC),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.attach_money_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Expenses",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text(
                    "${controller.expenses.length} expense${controller.expenses.length != 1 ? 's' : ''} recorded",
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ));
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _showExpenseDialog(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Add Expense"),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddCategoryDialog(context),
          icon: const Icon(Icons.local_offer_outlined, size: 18),
          label: const Text("Add Category"),
          style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFFF4EFFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDE7F6))),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.attach_money_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Expense",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              Obx(() {
                final formatter = NumberFormat('#,##,###');
                return Text("₹ ${formatter.format(controller.totalExpense)}",
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildFilterPill("All", "", controller.filterCategoryId.value == ""),
          ...controller.categories.map((cat) {
            String catId = cat.id.toString();
            bool isActive = controller.filterCategoryId.value == catId;
            return Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterPill(cat.name ?? "Unnamed", catId, isActive),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => controller.deleteCategory(cat.id, cat.name!),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.delete_outline,
                          size: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildFilterPill(String label, String id, bool active) {
    return InkWell(
      onTap: () => controller.filterCategoryId.value = id,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            color: active ? AppColors.primary : const Color(0xFFF4EFFC),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 48, color: Colors.yellow[600]),
          const SizedBox(height: 12),
          const Text("No Expenses Available",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const Text("Add your first expense to get started",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0F3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 800),
            child: DataTable(
              headingRowColor:
                  MaterialStateProperty.all(const Color(0xFFF4EFFC)),
              headingRowHeight: 50,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 60,
              horizontalMargin: 16,
              columns: [
                DataColumn(
                    label: Text("#",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
                DataColumn(
                    label: Text("Title",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
                DataColumn(
                    label: Text("Category",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
                DataColumn(
                    label: Text("Description",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
                DataColumn(
                    label: Text("Amount",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
                DataColumn(
                    label: Text("Payment Mode",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
                DataColumn(
                    label: Text("Actions",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
              ],
              rows: controller.filteredExpenses.asMap().entries.map((entry) {
                int idx = entry.key;
                var expense = entry.value;

                String pMode = expense.paymentMode?.toUpperCase() ?? "CASH";
                Color pModeBg = pMode == "CASH"
                    ? Colors.green[50]!
                    : pMode == "ONLINE"
                        ? Colors.blue[50]!
                        : const Color(0xFFF4EFFC);
                Color pModeText = pMode == "CASH"
                    ? Colors.green[600]!
                    : pMode == "ONLINE"
                        ? Colors.blue[600]!
                        : AppColors.primary;

                return DataRow(
                  cells: [
                    DataCell(Text("${idx + 1}",
                        style: const TextStyle(color: Colors.grey))),
                    DataCell(Text(expense.title ?? "-",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary))),
                    DataCell(Text(expense.categoryName ?? "-",
                        style: const TextStyle(color: Colors.grey))),
                    DataCell(Text(expense.description ?? "-",
                        style: const TextStyle(color: Colors.grey))),
                    DataCell(Text("₹ ${expense.amount}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: pModeBg,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(pMode,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: pModeText)),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                size: 18, color: Colors.grey),
                            onPressed: () => _showExpenseDialog(Get.context!,
                                expense: expense),
                            tooltip: "Edit Expense",
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: Colors.grey),
                            onPressed: () =>
                                controller.deleteExpense(expense.id),
                            tooltip: "Delete Expense",
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: controller.filteredExpenses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        var expense = controller.filteredExpenses[index];
        String pMode = expense.paymentMode?.toUpperCase() ?? "CASH";
        Color pModeBg = pMode == "CASH"
            ? Colors.green[50]!
            : pMode == "ONLINE"
                ? Colors.blue[50]!
                : const Color(0xFFF4EFFC);
        Color pModeText = pMode == "CASH"
            ? Colors.green[600]!
            : pMode == "ONLINE"
                ? Colors.blue[600]!
                : AppColors.primary;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E0F3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expense.title ?? "-",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(expense.categoryName ?? "-",
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text("₹ ${expense.amount}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              if (expense.description != null &&
                  expense.description!.isNotEmpty) ...[
                Text(expense.description!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
              ],
              const Divider(color: Color(0xFFE8E0F3), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: pModeBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(pMode,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: pModeText)),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () =>
                            _showExpenseDialog(Get.context!, expense: expense),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.edit_outlined,
                              size: 18, color: Colors.grey),
                        ),
                      ),
                      InkWell(
                        onTap: () => controller.deleteExpense(expense.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: "Category Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.addCategory(textController.text.trim());
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showExpenseDialog(BuildContext context, {dynamic expense}) {
    bool isEdit = expense != null;
    final TextEditingController titleCtrl =
        TextEditingController(text: isEdit ? expense.title : "");
    final TextEditingController descCtrl =
        TextEditingController(text: isEdit ? expense.description : "");
    final TextEditingController amountCtrl =
        TextEditingController(text: isEdit ? expense.amount.toString() : "");

    String selectedCategory = isEdit
        ? expense.category.toString()
        : (controller.filterCategoryId.value.isNotEmpty
            ? controller.filterCategoryId.value
            : (controller.categories.isNotEmpty
                ? controller.categories.first.id.toString()
                : ""));
    String selectedPaymentMode =
        isEdit ? (expense.paymentMode?.toUpperCase() ?? "CASH") : "CASH";

    Get.dialog(
      AlertDialog(
        title: Text(isEdit ? "Edit Expense" : "Add Expense"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: "Title", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory.isNotEmpty ? selectedCategory : null,
                decoration: const InputDecoration(
                    labelText: "Category", border: OutlineInputBorder()),
                items: controller.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id.toString(),
                    child: Text(cat.name ?? "Unknown"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedCategory = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                    labelText: "Description", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Amount", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPaymentMode,
                decoration: const InputDecoration(
                    labelText: "Payment Mode", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "CASH", child: Text("CASH")),
                  DropdownMenuItem(value: "ONLINE", child: Text("ONLINE")),
                ],
                onChanged: (val) {
                  if (val != null) selectedPaymentMode = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty ||
                  amountCtrl.text.isEmpty ||
                  selectedCategory.isEmpty) {
                Get.snackbar("Error", "Please fill required fields",
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              Map<String, dynamic> data = {
                "title": titleCtrl.text,
                "category": selectedCategory,
                "description": descCtrl.text,
                "amount": amountCtrl.text,
                "payment_mode": selectedPaymentMode,
                "stock_id": "0",
              };

              if (isEdit) {
                controller.editExpense(expense.id, data);
              } else {
                controller.addExpense(data);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: Text(isEdit ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }
}
