class UserModel {
  final int? id;
  final String username;
  final String? email;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      username: (json['username'] ?? '').toString().trim(),
      email: _normalizeEmail(json['email']),
    );
  }

  static String? _normalizeEmail(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
