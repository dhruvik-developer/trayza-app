class StockCategoryModel {
  final int? id;
  final String? name;

  StockCategoryModel({this.id, this.name});

  factory StockCategoryModel.fromJson(Map<String, dynamic> json) {
    return StockCategoryModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class StockItemModel {
  final int? id;
  final String? name;
  final int? category;
  final String? categoryName;
  final String? quantity;
  final String? alert;
  final String? type; // unit
  final String? ntePrice;
  final String? totalPrice;

  StockItemModel({
    this.id,
    this.name,
    this.category,
    this.categoryName,
    this.quantity,
    this.alert,
    this.type,
    this.ntePrice,
    this.totalPrice,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      categoryName: json['category_name'],
      quantity: json['quantity'],
      alert: json['alert'],
      type: json['type'],
      ntePrice: json['nte_price'],
      totalPrice: json['total_price'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'quantity': quantity,
    'alert': alert,
    'type': type,
    'nte_price': ntePrice,
    'total_price': totalPrice,
  };
}
