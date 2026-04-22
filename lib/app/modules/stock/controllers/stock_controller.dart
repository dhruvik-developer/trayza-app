import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trayza_app/app/core/theme/app_colors.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/stock_provider.dart';

class StockController extends GetxController {
  final StockProvider _provider = StockProvider();

  // State
  final isLoading = false.obs;
  final categories = <StockCategoryModel>[].obs;
  final items =
      <StockItemModel>[].obs; // This will hold items for current category
  final allItemsList = <StockItemModel>[].obs; // For stats
  final selectedCategoryId = "all_items".obs;
  final searchQuery = "".obs;

  // Stats
  final totalItems = 0.obs;
  final lowStockItems = 0.obs;
  final totalValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  // Reactive getter for filtered stocks
  List<StockItemModel> get filteredStocks {
    if (searchQuery.value.isEmpty) {
      return items;
    }
    return items.where((item) {
      final name = item.name?.toLowerCase() ?? "";
      final cat = item.categoryName?.toLowerCase() ?? "";
      final query = searchQuery.value.toLowerCase();
      return name.contains(query) || cat.contains(query);
    }).toList();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await fetchCategories();
      updateItemsList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _provider.getStockCategories();
      if (response.data != null) {
        final List? data = response.data['data'] ??
            response.data; // Handle React-like data wrapper
        if (data != null) {
          categories.value =
              data.map((json) => StockCategoryModel.fromJson(json)).toList();

          // Flatten all items for global stats
          final allItems = <StockItemModel>[];
          for (var cat in categories) {
            if (cat.stokeItems != null) {
              for (var item in cat.stokeItems!) {
                // Add category name if missing
                allItems.add(item.copyWithCategoryName(cat.name));
              }
            }
          }
          allItemsList.value = allItems;
          calculateStats();
        }
      }
    } catch (e) {
      log("Failed to fetch categories: $e");
      Get.snackbar("Error", "Failed to fetch categories: $e");
    }
  }

  void updateItemsList() {
    if (selectedCategoryId.value == "all_items") {
      items.value = allItemsList;
    } else if (selectedCategoryId.value == "low_stock") {
      items.value = allItemsList.where((item) {
        final qty = double.tryParse(item.quantity ?? "0") ?? 0;
        final alert = double.tryParse(item.alert ?? "0") ?? 0;
        return alert > 0 && qty <= alert;
      }).toList();
    } else {
      final category = categories.firstWhereOrNull(
          (cat) => cat.id.toString() == selectedCategoryId.value);
      if (category != null && category.stokeItems != null) {
        items.value = category.stokeItems!
            .map((i) => i.copyWithCategoryName(category.name))
            .toList();
      } else {
        items.value = [];
      }
    }
  }

  void calculateStats() {
    totalItems.value = allItemsList.length;
    lowStockItems.value = allItemsList.where((item) {
      final qty = double.tryParse(item.quantity ?? "0") ?? 0;
      final alert = double.tryParse(item.alert ?? "0") ?? 0;
      return alert > 0 && qty <= alert;
    }).length;

    totalValue.value = allItemsList.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item.totalPrice ?? "0") ?? 0);
    });
  }

  void onCategoryChanged(String? id) {
    if (id != null) {
      selectedCategoryId.value = id;
      updateItemsList();
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  // Stock Adjustment Methods

  Future<void> increaseStock(StockItemModel item) async {
    final qtyController = TextEditingController();
    final rateController = TextEditingController(text: item.ntePrice);
    final totalController = TextEditingController();

    void calculateTotal() {
      final q = double.tryParse(qtyController.text) ?? 0;
      final r = double.tryParse(rateController.text) ?? 0;
      if (q > 0 && r > 0) {
        totalController.text = (q * r).toStringAsFixed(2);
      }
    }

    qtyController.addListener(calculateTotal);
    rateController.addListener(calculateTotal);

    await _showCustomDialog(
      title: "Add Stock For: ${item.name}",
      content: [
        _buildDialogField(qtyController, "Quantity Per ${item.type ?? ""}",
            hint: "Please Enter To Add Stock", isNumber: true),
        _buildDialogField(rateController, "Rate Per ${item.type ?? ""}",
            hint: "Please Enter Rate Per Unit", isNumber: true),
        _buildDialogField(totalController, "Total Amount",
            hint: "Please Enter Total Price", isNumber: true),
      ],
      confirmText: "Submit",
      onConfirm: () async {
        if (qtyController.text.isNotEmpty) {
          await _provider.increaseStock({
            "id": item.id,
            "quantity": qtyController.text,
            "nte_price": rateController.text,
            "total_price": totalController.text,
          });
          Get.snackbar("Success", "Stock increased for ${item.name}",
              backgroundColor: Colors.white, colorText: Colors.black);
        }
      },
    );
  }

  Future<void> decreaseStock(StockItemModel item) async {
    final qtyController = TextEditingController();
    final rateController = TextEditingController(text: item.ntePrice);
    final totalController = TextEditingController();

    void calculateTotal() {
      final q = double.tryParse(qtyController.text) ?? 0;
      final r = double.tryParse(rateController.text) ?? 0;
      if (q > 0 && r > 0) {
        totalController.text = (q * r).toStringAsFixed(2);
      }
    }

    qtyController.addListener(calculateTotal);

    await _showCustomDialog(
      title: "Remove Stock For: ${item.name}",
      confirmText: "Submit",
      content: [
        _buildDialogField(qtyController, "Quantity Per ${item.type ?? ""}",
            hint: "Please Enter To Remove Stock", isNumber: true),
        _buildDialogField(rateController, "Rate Per ${item.type ?? ""}",
            isReadOnly: true),
        _buildDialogField(totalController, "Total Amount",
            hint: "Please Enter Total Price", isNumber: true),
      ],
      onConfirm: () async {
        if (qtyController.text.isNotEmpty) {
          await _provider.decreaseStock({
            "id": item.id,
            "quantity": qtyController.text,
            "nte_price": rateController.text,
            "total_price": totalController.text,
          });
          Get.snackbar("Success", "Stock decreased for ${item.name}",
              backgroundColor: Colors.white, colorText: Colors.black);
        }
      },
    );
  }

  Future<void> addItem() async {
    final nameController = TextEditingController();
    final typeController = "KG".obs;
    final qtyController = TextEditingController();
    final alertController = TextEditingController();
    final rateController = TextEditingController();
    final totalController = TextEditingController();

    void calculateTotal() {
      final q = double.tryParse(qtyController.text) ?? 0;
      final r = double.tryParse(rateController.text) ?? 0;
      if (q > 0 && r > 0) {
        totalController.text = (q * r).toStringAsFixed(2);
      }
    }

    qtyController.addListener(calculateTotal);
    rateController.addListener(calculateTotal);

    await _showCustomDialog(
      title: "Add Item",
      confirmText: "Submit",
      content: [
        _buildDialogField(nameController, "Item Name",
            hint: "Please Enter Item Name"),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Type",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E0F3))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: typeController.value,
                      isExpanded: true,
                      onChanged: (v) => typeController.value = v!,
                      items: const [
                        DropdownMenuItem(value: "KG", child: Text("Kilogram")),
                        DropdownMenuItem(value: "G", child: Text("Gram")),
                        DropdownMenuItem(value: "L", child: Text("Litre")),
                        DropdownMenuItem(
                            value: "ML", child: Text("Millilitre")),
                        DropdownMenuItem(value: "QTY", child: Text("Quantity")),
                      ],
                    ),
                  ),
                ),
              ],
            )),
        Obx(() => _buildDialogField(
            qtyController, "Quantity Per ${typeController.value}",
            hint: "Please Enter Quantity", isNumber: true)),
        Obx(() => _buildDialogField(
            alertController, "Alert Per ${typeController.value}",
            hint: "Please Enter Alert Quantity", isNumber: true)),
        Obx(() => _buildDialogField(
            rateController, "Rate Per ${typeController.value}",
            hint: "Please Enter Rate Per Unit", isNumber: true)),
        _buildDialogField(totalController, "Total Amount",
            hint: "Please Enter Total Price", isNumber: true),
      ],
      onConfirm: () async {
        if (qtyController.text.isNotEmpty) {
          await _provider.addStockItem({
            "category": selectedCategoryId.value,
            "name": nameController.text,
            "type": typeController.value,
            "quantity": qtyController.text,
            "alert": alertController.text,
            "nte_price": rateController.text,
            "total_price": totalController.text,
          });
        }
      },
    );
  }

  Future<void> addCategory() async {
    final nameController = TextEditingController();
    await _showCustomDialog(
      title: "Add Category",
      confirmText: "Submit",
      content: [
        _buildDialogField(nameController, "Category Name",
            hint: "Please Enter Category Name"),
      ],
      onConfirm: () async {
        if (nameController.text.trim().isEmpty) {
          throw "Please enter a category name";
        }
        await _provider.addStockCategory(nameController.text.trim());
      },
    );
  }

  Future<void> deleteItem(StockItemModel item) async {
    await _showCustomDialog(
      title: "Delete Item",
      confirmText: "Delete",
      content: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: "Are you sure you want to delete "),
                TextSpan(
                  text: "'${item.name}'",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(text: "?\n\nThis action cannot be undone."),
              ],
            ),
          ),
        ),
      ],
      onConfirm: () async {
        await _provider.deleteStockItem(item.id!);
      },
    );
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _provider.deleteStockCategory(int.parse(id));
      // Reset selection to "All Items" to avoid dropdown value error after deletion
      selectedCategoryId.value = "all_items";
      fetchData();
      Get.snackbar("Success", "Category deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete category");
    }
  }

  // --- Premium UI Dialog Helper Methods ---

  Widget _buildDialogField(TextEditingController controller, String label,
      {String? hint, bool isNumber = false, bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF444444))),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
              filled: true,
              fillColor: isReadOnly ? Colors.grey[100] : Colors.white,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE8E0F3))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomDialog({
    required String title,
    required List<Widget> content,
    required String confirmText,
    required Future<void> Function() onConfirm,
  }) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: Get.width * 0.95,
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF555555))),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: content),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Submit
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () async {
                        log("Dialog: Submit clicked");
                        try {
                          await onConfirm();
                          log("Dialog: onConfirm finished");
                          if (Get.isDialogOpen ?? true) {
                            log("Dialog: Forcefully closing dialog...");
                            Navigator.of(Get.context!).pop();
                          }
                          fetchData();
                        } catch (e) {
                          log("Dialog: Error - $e");
                          Get.snackbar("Error", e.toString(),
                              backgroundColor: Colors.white,
                              colorText: Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(confirmText,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cancel
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6c757d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add copyWithCategoryName extension to StockItemModel or just use a helper
extension StockItemExt on StockItemModel {
  StockItemModel copyWithCategoryName(String? categoryName) {
    return StockItemModel(
      id: id,
      name: name,
      category: category,
      categoryName: categoryName ?? this.categoryName,
      quantity: quantity,
      alert: alert,
      type: type,
      ntePrice: ntePrice,
      totalPrice: totalPrice,
    );
  }
}
