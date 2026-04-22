class GroundChecklistItem {
  final int id;
  final String name;
  final int? categoryId;
  final String? unit;
  final String? description;
  final bool isActive;

  const GroundChecklistItem({
    required this.id,
    required this.name,
    this.categoryId,
    this.unit,
    this.description,
    this.isActive = true,
  });

  factory GroundChecklistItem.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];

    return GroundChecklistItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      categoryId: rawCategory is int
          ? rawCategory
          : rawCategory is Map<String, dynamic>
              ? rawCategory['id'] is int
                  ? rawCategory['id'] as int
                  : int.tryParse('${rawCategory['id']}')
              : int.tryParse('${json['category_id'] ?? ''}'),
      unit: json['unit']?.toString(),
      description: json['description']?.toString(),
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : '${json['is_active']}'.toLowerCase() != 'false',
    );
  }
}

class GroundChecklistCategory {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final List<GroundChecklistItem> groundItems;

  const GroundChecklistCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.groundItems = const [],
  });

  factory GroundChecklistCategory.fromJson(Map<String, dynamic> json) {
    final rawItems = json['ground_items'] ?? json['items'] ?? const [];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) =>
                GroundChecklistItem.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <GroundChecklistItem>[];

    return GroundChecklistCategory(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : '${json['is_active']}'.toLowerCase() != 'false',
      groundItems: items,
    );
  }
}
