class PermissionItemModel {
  const PermissionItemModel({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;

  factory PermissionItemModel.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] ?? json['permission_code'] ?? json['permission'])
        .toString()
        .trim();
    final name = (json['name'] ?? json['label'] ?? code).toString().trim();
    return PermissionItemModel(code: code, name: name.isEmpty ? code : name);
  }
}

class PermissionModuleModel {
  const PermissionModuleModel({
    required this.name,
    required this.permissions,
  });

  final String name;
  final List<PermissionItemModel> permissions;

  factory PermissionModuleModel.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'] ?? json['actions'] ?? [];
    final permissions = rawPermissions is List
        ? rawPermissions
            .whereType<Map>()
            .map((entry) =>
                PermissionItemModel.fromJson(Map<String, dynamic>.from(entry)))
            .where((entry) => entry.code.isNotEmpty)
            .toList()
        : <PermissionItemModel>[];

    final name = (json['name'] ?? json['module'] ?? json['title'] ?? 'Module')
        .toString()
        .trim();

    return PermissionModuleModel(
      name: name.isEmpty ? 'Module' : name,
      permissions: permissions,
    );
  }
}

class PermissionSubjectModel {
  const PermissionSubjectModel({
    required this.id,
    required this.name,
    this.subtitle,
  });

  final int id;
  final String name;
  final String? subtitle;

  String get avatarLabel =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  factory PermissionSubjectModel.fromJson(Map<String, dynamic> json) {
    final parsedId = _resolveId(json);
    if (parsedId == null) {
      throw const FormatException('Permission subject id is missing');
    }

    final user = _mapOrNull(json['user']);
    final userAccount = _mapOrNull(json['user_account']);
    final linkedUser = _mapOrNull(json['linked_user']);

    final name = (json['name'] ??
            json['staff_name'] ??
            json['username'] ??
            json['full_name'] ??
            json['vendor_name'] ??
            json['company_name'] ??
            json['contact_person'] ??
            json['contact_name'] ??
            user?['name'] ??
            user?['username'] ??
            userAccount?['name'] ??
            userAccount?['username'] ??
            linkedUser?['name'] ??
            linkedUser?['username'] ??
            json['linked_username'] ??
            'Unnamed')
        .toString()
        .trim();
    final subtitle = _normalizeSubtitle(
      json['phone'] ??
          json['mobile'] ??
          json['mobile_no'] ??
          json['mobile_number'] ??
          json['email'] ??
          user?['phone'] ??
          user?['mobile'] ??
          user?['email'] ??
          userAccount?['phone'] ??
          userAccount?['mobile'] ??
          userAccount?['email'] ??
          linkedUser?['phone'] ??
          linkedUser?['mobile'] ??
          linkedUser?['email'],
    );

    return PermissionSubjectModel(
      id: parsedId,
      name: name.isEmpty ? 'Unnamed' : name,
      subtitle: subtitle,
    );
  }

  static String? _normalizeSubtitle(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static int? _resolveId(Map<String, dynamic> json) {
    return _parseInt(
          json['linked_user_id'],
        ) ??
        _parseInt(
          json['user_id'],
        ) ??
        _parseInt(
          _mapOrNull(json['linked_user'])?['id'],
        ) ??
        _parseInt(
          _mapOrNull(json['user_account'])?['id'],
        ) ??
        _parseInt(
          _mapOrNull(json['user'])?['id'],
        ) ??
        _parseInt(
          json['id'],
        );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse('${value ?? ''}');
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
