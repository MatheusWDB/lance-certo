import 'package:lance_certo/models/user_role.dart';

class User {
  User({
    this.userId,
    this.username,
    this.email,
    this.password,
    this.name,
    this.phone,
    this.role,
    this.token,
  });

  final int? userId;
  final String? username;
  final String? email;
  final String? password;
  final String? name;
  final String? phone;
  final UserRole? role;
  final String? token;

  static User? currentUser;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      role: UserRole.values[json['role']],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson(
    String? login,
    String? currentPassword,
    String? newPassword,
  ) => {
    'login': login,
    'password': password,
    'username': username,
    'email': email,
    'name': name,
    'phone': phone,
    'role': role,
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
