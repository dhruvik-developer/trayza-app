class StockCategoryModel {
  final int? id;
  final String? name;
  final List<StockItemModel>? stokeItems;

  StockCategoryModel({this.id, this.name, this.stokeItems});

  factory StockCategoryModel.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['stokeitem'] ?? json['stoke_item'] ?? json['items'];
    List<StockItemModel>? items;
    if (itemsJson != null) {
      items = (itemsJson as List).map((i) => StockItemModel.fromJson(i)).toList();
    }
    
    return StockCategoryModel(
      id: json['id'],
      name: json['name'],
      stokeItems: items,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stokeitem': stokeItems?.map((e) => e.toJson()).toList(),
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
      quantity: json['quantity']?.toString(),
      alert: json['alert']?.toString(),
      type: json['type']?.toString(),
      ntePrice: json['nte_price']?.toString(),
      totalPrice: json['total_price']?.toString(),
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
