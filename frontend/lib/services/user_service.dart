import 'dart:convert';

import 'package:lance_certo/models/user.dart';
import 'package:http/http.dart' as http;

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
      throw Exception('Erro ao criar usuário: ${data['message']}');
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
    if (response.statusCode == 200) {
      final Map<String, dynamic> userMap = data['userDTO'];
      final loggedUser = User.fromJson(userMap);
      loggedUser.token = data['token'];
      User.currentUser = loggedUser;
    } else {
      throw Exception('Erro ao buscar usuário: ${data['message']}');
    }
  }

  static Future<void> updateUser(
    User user,
    String currentPassword,
    String newPassword,
  ) async {
    final String token = User.currentUser!.token!;

    final response = await http.patch(
      Uri.parse('$baseUrl/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson(null, currentPassword, newPassword)),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loggedUser = User.fromJson(data);
      User.currentUser = loggedUser;
    } else {
      throw Exception('Erro ao buscar usuário: ${response.statusCode}');
    }
  }
}
