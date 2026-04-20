class IngredientItemModel {
  final int id;
  final String name;
  final int? category;

  IngredientItemModel({
    required this.id,
    required this.name,
    this.category,
  });

  factory IngredientItemModel.fromJson(Map<String, dynamic> json) {
    return IngredientItemModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'],
    );
  }
}

class IngredientCategoryModel {
  final int id;
  final String name;
  final bool isCommon;
  final List<IngredientItemModel> items;

  IngredientCategoryModel({
    required this.id,
    required this.name,
    this.isCommon = false,
    this.items = const [],
  });

  factory IngredientCategoryModel.fromJson(Map<String, dynamic> json) {
    final List itemData = json['items'] ?? [];
    return IngredientCategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      isCommon: json['is_common'] ?? false,
      items: itemData.map((e) => IngredientItemModel.fromJson(e)).toList(),
    );
  }
}
