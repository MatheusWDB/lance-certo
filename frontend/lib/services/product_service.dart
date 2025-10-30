import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/models/user.dart';

class ProductService {
  static String address = dotenv.get('URL');
  static String baseUrl = 'http://$address/api/products';

  static String? _getAuthToken() {
    return User.token;
  }

  static Future<List<Product>> fetchProductsBySeller() async {
    final response = await http.get(
      Uri.parse('$baseUrl/seller'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    final List<dynamic> jsonList = data;

    return jsonList
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create/sellers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }
  }
}
