import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/expense_category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/providers/expense_provider.dart';

class ExpenseController extends GetxController {
  final ExpenseProvider _provider = ExpenseProvider();

  var expenses = <ExpenseModel>[].obs;
  var categories = <ExpenseCategoryModel>[].obs;
  var isLoading = true.obs;
  var filterCategoryId = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchExpenses(),
        fetchCategories(),
      ]);
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExpenses() async {
    try {
      final response = await _provider.getExpenses();
      if (response.data['status'] == true) {
        final List data = response.data['data'];
        expenses.value = data.map((e) => ExpenseModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _provider.getExpenseCategories();
      if (response.data['status'] == true) {
        final List data = response.data['data'];
        categories.value =
            data.map((e) => ExpenseCategoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  List<ExpenseModel> get filteredExpenses {
    if (filterCategoryId.value == "") {
      return expenses;
    }
    return expenses
        .where((exp) => exp.category.toString() == filterCategoryId.value)
        .toList();
  }

  double get totalExpense {
    return filteredExpenses.fold(
        0.0, (sum, exp) => sum + double.parse(exp.amount));
  }

  Future<void> addExpense(Map<String, dynamic> data) async {
    try {
      final response = await _provider.createExpense(data);
      if (response.data != null) {
        await fetchExpenses();
        Get.back();
        Get.snackbar("Success", "Expense added successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add expense");
    }
  }

  Future<void> editExpense(int id, Map<String, dynamic> data) async {
    try {
      final response = await _provider.updateExpense(id, data);
      if (response.data != null) {
        await fetchExpenses();
        Get.back();
        Get.snackbar("Success", "Expense updated successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update expense");
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      final response = await _provider.deleteExpense(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchExpenses();
        Get.snackbar("Success", "Expense deleted successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete expense");
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final response = await _provider.createExpenseCategory(name);
      if (response.data != null) {
        await fetchCategories();
        Get.snackbar("Success", "Category added successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add category");
    }
  }

  Future<void> deleteCategory(int id, String name) async {
    final categoryExpenses = expenses
        .where((exp) => exp.category.toString() == id.toString())
        .toList();

    if (categoryExpenses.isNotEmpty) {
      double catTotal = categoryExpenses.fold(
          0.0, (sum, exp) => sum + double.parse(exp.amount));

      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("⚠️ Category Has Existing Data!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("The category \"$name\" has:"),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text("📋 ${categoryExpenses.length} expense(s)"),
                    Text("💰 Total: ₹ $catTotal"),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text("All associated expenses will be deleted first!",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text("Cancel")),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text("Yes, delete anyway!",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      for (var exp in categoryExpenses) {
        await _provider.deleteExpense(exp.id);
      }
    }

    try {
      await _provider.deleteExpenseCategory(id);
      await fetchCategories();
      await fetchExpenses();
      Get.snackbar("Success", "Category deleted successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete category");
    }
  }
}
