class UserModel {
  final String id;
  final String email;
  final String? tenantId;
  final String? firstName;
  final String? lastName;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    this.tenantId,
    this.firstName,
    this.lastName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      tenantId: json['tenantId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
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
      'role': role,
    };
  }
}
