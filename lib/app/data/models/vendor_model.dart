class VendorModel {
  final int? id;
  final String? name;
  final String? contactPerson;
  final String? mobile;
  final String? category;
  final String? address;

  VendorModel({
    this.id,
    this.name,
    this.contactPerson,
    this.mobile,
    this.category,
    this.address,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'],
      name: json['name'],
      contactPerson: json['contact_person'],
      mobile: json['mobile_number'] ?? json['mobile'],
      category: json['category_name'] ?? json['category'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'contact_person': contactPerson,
    'mobile_number': mobile,
    'category': category,
    'address': address,
  };
}
