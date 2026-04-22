import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/ground_checklist_model.dart';
import '../../../data/providers/ground_checklist_provider.dart';

class GroundChecklistController extends GetxController {
  GroundChecklistController();

  final GroundChecklistProvider _provider = GroundChecklistProvider();

  final searchController = TextEditingController();
  final categories = <GroundChecklistCategory>[].obs;
  final isLoading = false.obs;
  final selectedCategoryId = RxnInt();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  GroundChecklistCategory? get activeCategory {
    if (categories.isEmpty) return null;

    if (selectedCategoryId.value == null) {
      return categories.first;
    }

    for (final category in categories) {
      if (category.id == selectedCategoryId.value) {
        return category;
      }
    }

    return categories.first;
  }

  List<GroundChecklistCategory> get activeCategoriesOnly =>
      categories.where((category) => category.isActive).toList();

  List<GroundChecklistItem> get filteredItems {
    final items = activeCategory?.groundItems ?? const <GroundChecklistItem>[];
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) return items;

    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  int get totalItems => categories.fold<int>(
      0, (count, category) => count + category.groundItems.length);

  void selectCategory(int id) {
    selectedCategoryId.value = id;
    searchQuery.value = '';
    searchController.clear();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;

    try {
      final response = await _provider.getGroundCategories();
      final rawData = response.data;

      List<dynamic> categoryList = const [];
      if (rawData is List) {
        categoryList = rawData;
      } else if (rawData is Map<String, dynamic>) {
        final extracted =
            rawData['data'] ?? rawData['results'] ?? rawData['categories'];
        categoryList = extracted is List ? extracted : const [];
      } else if (rawData is Map) {
        final extracted =
            rawData['data'] ?? rawData['results'] ?? rawData['categories'];
        categoryList = extracted is List ? extracted : const [];
      }

      final parsed = categoryList
          .whereType<Map>()
          .map((json) =>
              GroundChecklistCategory.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      categories.assignAll(parsed);

      if (categories.isEmpty) {
        selectedCategoryId.value = null;
      } else {
        final currentId = selectedCategoryId.value;
        final stillExists =
            currentId != null && categories.any((item) => item.id == currentId);
        selectedCategoryId.value =
            stillExists ? currentId : categories.first.id;
      }
    } catch (error) {
      log('Failed to load ground checklist: $error');
      Get.snackbar(
        'Error',
        'Failed to load ground checklist',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCategory({
    int? id,
    required String name,
    String description = '',
    required bool isActive,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      Get.snackbar(
        'Required',
        'Category name is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final duplicate = categories.any((category) =>
        category.id != id &&
        category.name.trim().toLowerCase() == trimmedName.toLowerCase());
    if (duplicate) {
      Get.snackbar(
        'Duplicate',
        'Category name already exists',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final payload = {
      'name': trimmedName,
      'description': description.trim(),
      'is_active': isActive,
    };

    try {
      if (id == null) {
        await _provider.createGroundCategory(payload);
      } else {
        await _provider.updateGroundCategory(id, payload);
      }

      await fetchCategories();
      Get.back<void>();
      Get.snackbar(
        'Success',
        id == null
            ? 'Category created successfully'
            : 'Category updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      log('Failed to save category: $error');
      Get.snackbar(
        'Error',
        'Failed to save category',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveItem({
    int? id,
    required String name,
    required int categoryId,
    required String unit,
    String description = '',
    required bool isActive,
  }) async {
    final trimmedName = name.trim();
    final trimmedUnit = unit.trim();

    if (trimmedName.isEmpty || trimmedUnit.isEmpty) {
      Get.snackbar(
        'Required',
        'Item name, category and unit are required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final duplicate = categories.any((category) => category.groundItems.any(
        (item) =>
            item.id != id &&
            item.categoryId == categoryId &&
            item.name.trim().toLowerCase() == trimmedName.toLowerCase()));
    if (duplicate) {
      Get.snackbar(
        'Duplicate',
        'Item name already exists in this category',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final payload = {
      'name': trimmedName,
      'category': categoryId,
      'unit': trimmedUnit,
      'description': description.trim(),
      'is_active': isActive,
    };

    try {
      if (id == null) {
        await _provider.createGroundItem(payload);
      } else {
        await _provider.updateGroundItem(id, payload);
      }

      await fetchCategories();
      if (selectedCategoryId.value != categoryId) {
        selectedCategoryId.value = categoryId;
      }
      Get.back<void>();
      Get.snackbar(
        'Success',
        id == null ? 'Item created successfully' : 'Item updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      log('Failed to save item: $error');
      Get.snackbar(
        'Error',
        'Failed to save item',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteCategory(GroundChecklistCategory category) async {
    final confirmed = await _confirmDelete(
      title: 'Delete Category?',
      message: 'Delete "${category.name}" and all items inside this category?',
    );
    if (confirmed != true) return;

    try {
      await _provider.deleteGroundCategory(category.id);
      await fetchCategories();
      Get.snackbar(
        'Success',
        'Category deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      log('Failed to delete category: $error');
      Get.snackbar(
        'Error',
        'Failed to delete category',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteItem(GroundChecklistItem item) async {
    final confirmed = await _confirmDelete(
      title: 'Delete Item?',
      message: 'Delete "${item.name}" from this checklist?',
    );
    if (confirmed != true) return;

    try {
      await _provider.deleteGroundItem(item.id);
      await fetchCategories();
      Get.snackbar(
        'Success',
        'Item deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      log('Failed to delete item: $error');
      Get.snackbar(
        'Error',
        'Failed to delete item',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool?> _confirmDelete({
    required String title,
    required String message,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
