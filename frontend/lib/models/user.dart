import 'package:lance_certo/models/user_role.dart';

class User {
  User({
    this.id,
    this.username,
    this.email,
    this.name,
    this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  final int? id;
  String? username;
  String? email;
  String? name;
  String? phone;
  UserRole? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  String? token;

  static User? currentUser;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] != null
          ? UserRole.fromString(json['role'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson(
    String? login,
    String? currentPassword,
    String? newPassword,
  ) => {
    'login': login,
    'password': currentPassword,
    'username': username,
    'email': email,
    'name': name,
    'phone': phone,
    'role': role?.name,
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
