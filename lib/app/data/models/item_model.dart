class ItemCategoryModel {
  final int? id;
  final String? name;
  final int? positions;
  final List<ItemModel>? items;

  ItemCategoryModel({this.id, this.name, this.positions, this.items});

  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      id: json['id'],
      name: json['name'],
      positions: json['positions'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => ItemModel.fromJson(i)).toList()
          : [],
    );
  }
}

class ItemModel {
  final int? id;
  final String? name;
  final String? categoryName;
  final int? categoryPosition;

  ItemModel({this.id, this.name, this.categoryName, this.categoryPosition});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      categoryName: json['category_name'],
      categoryPosition: json['category_positions'],
    );
  }
}
