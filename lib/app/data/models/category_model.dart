class CategoryItemModel {
  final int id;
  final String name;
  final int? category;
  final String? baseCost;
  final String? selectionRate;
  final bool hasRecipe;

  CategoryItemModel({
    required this.id,
    required this.name,
    this.category,
    this.baseCost,
    this.selectionRate,
    this.hasRecipe = false,
  });

  factory CategoryItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryItemModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'],
      baseCost: json['base_cost'] ?? '',
      selectionRate: json['selection_rate'] ?? '',
      hasRecipe: json['has_recipe'] ?? false,
    );
  }

  CategoryItemModel copyWith({bool? hasRecipe}) {
    return CategoryItemModel(
      id: id,
      name: name,
      category: category,
      baseCost: baseCost,
      selectionRate: selectionRate,
      hasRecipe: hasRecipe ?? this.hasRecipe,
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final int? positions;
  final List<CategoryItemModel> items;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.positions,
    this.items = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final List itemData = json['items'] ?? [];
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      positions: json['positions'],
      items: itemData.map((e) => CategoryItemModel.fromJson(e)).toList(),
    );
  }
}
