class VendorModel {
  final int? id;
  final String? name;
  final String? contactPerson;
  final String? mobile;
  final String? category;
  final String? address;
  final bool isActive;
  final List<VendorCategoryModel> vendorCategories;

  VendorModel({
    this.id,
    this.name,
    this.contactPerson,
    this.mobile,
    this.category,
    this.address,
    this.isActive = true,
    this.vendorCategories = const [],
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['vendor_categories'] ?? json['categories'];
    final categories = rawCategories is List
        ? rawCategories
            .whereType<Map>()
            .map((entry) =>
                VendorCategoryModel.fromJson(Map<String, dynamic>.from(entry)))
            .toList()
        : <VendorCategoryModel>[];

    return VendorModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: _asString(json['name']) ??
          _asString(json['vendor_name']) ??
          _asString(json['company_name']),
      contactPerson:
          _asString(json['contact_person']) ?? _asString(json['contact_name']),
      mobile: _asString(json['mobile_number']) ??
          _asString(json['mobile']) ??
          _asString(json['mobile_no']) ??
          _asString(json['phone']),
      category: _asString(json['category_name']) ?? _asString(json['category']),
      address: _asString(json['address']),
      isActive: _asBool(json['is_active'], defaultValue: true),
      vendorCategories: categories,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact_person': contactPerson,
        'mobile_number': mobile,
        'category': category,
        'address': address,
        'is_active': isActive,
        'vendor_categories': vendorCategories.map((entry) => entry.toJson()),
      };

  static String? _asString(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static bool _asBool(dynamic value, {required bool defaultValue}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'active') {
      return true;
    }
    if (normalized == 'false' ||
        normalized == '0' ||
        normalized == 'inactive') {
      return false;
    }
    return defaultValue;
  }
}

class VendorCategoryModel {
  final int? id;
  final String categoryName;
  final double? price;

  VendorCategoryModel({
    required this.id,
    required this.categoryName,
    required this.price,
  });

  factory VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    return VendorCategoryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      categoryName: (json['category_name'] ?? json['name'] ?? 'Category')
          .toString()
          .trim(),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_name': categoryName,
        'price': price,
      };
}
