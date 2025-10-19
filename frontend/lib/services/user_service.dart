import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lance_certo/models/user.dart';

class UserService {
  static const String baseUrl = 'http://127.0.0.1:8080/api/users';

  static Future<void> registerUser(User user, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson(null, password, null)),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }
  }

  static Future<void> login(String login, String password) async {
    final User user = User();
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson(login, password, null)),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    final Map<String, dynamic> userMap = data['userDTO'];
    final loggedUser = User.fromJson(userMap);
    User.token = data['token'];
    User.currentUser = loggedUser;
  }

  static Future<void> updateUser(
    User user,
    String currentPassword,
    String newPassword,
  ) async {
    final String token = User.token!;

    final response = await http.patch(
      Uri.parse('$baseUrl/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson(null, currentPassword, newPassword)),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    final loggedUser = User.fromJson(data);
    User.currentUser = loggedUser;
  }
}
