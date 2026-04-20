class StaffModel {
  final int? id;
  final String? name;
  final String? mobile;
  final String? type; // 'fixed' or 'waiter'
  final String? role;
  final double? salary;

  StaffModel({
    this.id,
    this.name,
    this.mobile,
    this.type,
    this.role,
    this.salary,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      type: json['staff_type'], // Mapping 'staff_type' from API to 'type'
      role: json['role_name'] ?? json['role'],
      salary: json['salary'] != null ? double.tryParse(json['salary'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mobile': mobile,
    'staff_type': type,
    'role': role,
    'salary': salary,
  };
}

class WaiterTypeModel {
  final int? id;
  final String? name;
  final double? rate;

  WaiterTypeModel({this.id, this.name, this.rate});

  factory WaiterTypeModel.fromJson(Map<String, dynamic> json) {
    return WaiterTypeModel(
      id: json['id'],
      name: json['name'],
      rate: json['rate'] != null ? double.tryParse(json['rate'].toString()) : null,
    );
  }
}
