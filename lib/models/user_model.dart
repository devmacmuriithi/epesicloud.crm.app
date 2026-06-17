class UserModel {
  final String id;
  final String email;
  final String? tenantId;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    this.tenantId,
    this.firstName,
    this.lastName,
    this.name,
    required this.role,
  });

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    final first = firstName ?? '';
    final last = lastName ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : email.split('@').first;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      tenantId: json['tenantId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      name: json['name'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'tenantId': tenantId,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'role': role,
    };
  }
}
