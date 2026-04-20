import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/category_provider.dart';

class CategoryController extends GetxController {
  final CategoryProvider _categoryProvider = CategoryProvider();
  
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final response = await _categoryProvider.getCategories();
      if (response.data['status'] == true) {
        final List data = response.data['data'];
        categories.assignAll(data.map((e) => CategoryModel.fromJson(e)).toList());
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories");
    } finally {
      isLoading.value = false;
    }
  }
}
