import 'stock_model.dart';

class RecipeModel {
  final int? id;
  final int? item;
  final StockItemModel? ingredient; // Links to Stock inventory
  final String? quantity;
  final String? unit;
  final int? personCount;

  RecipeModel({
    this.id,
    this.item,
    this.ingredient,
    this.quantity,
    this.unit,
    this.personCount,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      item: json['item'],
      ingredient: json['ingredient'] != null 
          ? (json['ingredient'] is Map ? StockItemModel.fromJson(json['ingredient']) : null)
          : null,
      quantity: json['quantity']?.toString(),
      unit: json['unit'],
      personCount: json['person_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'item': item,
    'ingredient': ingredient?.id,
    'quantity': quantity,
    'unit': unit,
    'person_count': personCount,
  };
}
