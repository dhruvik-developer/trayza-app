class StaffModel {
  final int? id;
  final String? name;
  final String? mobile;
  final String? type;
  final String? role;
  final double? salary;
  final String? waiterTypeName;
  final String? agencyName;
  final double? perPersonRate;
  final double? fixedSalary;
  final double? contractRate;
  final bool isActive;

  StaffModel({
    this.id,
    this.name,
    this.mobile,
    this.type,
    this.role,
    this.salary,
    this.waiterTypeName,
    this.agencyName,
    this.perPersonRate,
    this.fixedSalary,
    this.contractRate,
    this.isActive = true,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    final parsedType = _asString(json['staff_type']) ?? _asString(json['type']);
    final parsedPerPersonRate =
        _asDouble(json['per_person_rate']) ?? _asDouble(json['salary']);
    final parsedFixedSalary =
        _asDouble(json['fixed_salary']) ?? _asDouble(json['monthly_salary']);
    final parsedContractRate =
        _asDouble(json['contract_rate']) ?? _asDouble(json['contract_amount']);

    return StaffModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: _asString(json['name']) ?? _asString(json['staff_name']),
      mobile: _asString(json['mobile']) ??
          _asString(json['mobile_no']) ??
          _asString(json['phone']),
      type: parsedType,
      role: _asString(json['role_name']) ?? _asString(json['role']),
      salary: _asDouble(json['salary']) ??
          parsedFixedSalary ??
          parsedContractRate ??
          parsedPerPersonRate,
      waiterTypeName: _asString(json['waiter_type_name']) ??
          _asString(json['waiter_type']?['name']),
      agencyName:
          _asString(json['agency_name']) ?? _asString(json['agency']?['name']),
      perPersonRate: parsedPerPersonRate,
      fixedSalary: parsedFixedSalary,
      contractRate: parsedContractRate,
      isActive: _asBool(json['is_active'], defaultValue: true),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'staff_type': type,
        'role': role,
        'salary': salary,
        'waiter_type_name': waiterTypeName,
        'agency_name': agencyName,
        'per_person_rate': perPersonRate,
        'fixed_salary': fixedSalary,
        'contract_rate': contractRate,
        'is_active': isActive,
      };

  bool get isFixed =>
      (type ?? '').trim().toLowerCase() == 'fixed' && (fixedSalary ?? 0) > 0;

  bool get isContract =>
      (type ?? '').trim().toLowerCase() == 'contract' &&
      (contractRate ?? 0) > 0;

  String get displayType {
    final raw = (type ?? '').trim();
    if (raw.isEmpty) return 'Staff';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  static String? _asString(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
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

class WaiterTypeModel {
  final int? id;
  final String? name;
  final double? rate;
  final String? description;
  final bool isActive;

  WaiterTypeModel({
    this.id,
    this.name,
    this.rate,
    this.description,
    this.isActive = true,
  });

  factory WaiterTypeModel.fromJson(Map<String, dynamic> json) {
    return WaiterTypeModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: StaffModel._asString(json['name']),
      rate: StaffModel._asDouble(json['per_person_rate']) ??
          StaffModel._asDouble(json['rate']),
      description: StaffModel._asString(json['description']),
      isActive: StaffModel._asBool(json['is_active'], defaultValue: true),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'per_person_rate': rate,
        'description': description,
        'is_active': isActive,
      };
}
