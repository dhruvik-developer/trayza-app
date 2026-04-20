class CategoryItemModel {
  final int id;
  final String name;
  final int? category;
  final double? baseCost;
  final double? selectionRate;

  CategoryItemModel({
    required this.id,
    required this.name,
    this.category,
    this.baseCost,
    this.selectionRate,
  });

  factory CategoryItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryItemModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'],
      baseCost: (json['base_cost'] ?? 0.0).toDouble(),
      selectionRate: (json['selection_rate'] ?? 0.0).toDouble(),
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final List<CategoryItemModel> items;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.items = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final List itemData = json['items'] ?? [];
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      items: itemData.map((e) => CategoryItemModel.fromJson(e)).toList(),
    );
  }
}
