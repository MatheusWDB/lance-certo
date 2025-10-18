import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/models/user.dart';

class ProductService {
  static const String baseUrl = 'http://127.0.0.1:8080/api/products';

  static String token = User.currentUser!.token!;

  static Future<List<Product>> fetchProductsBySeller() async {
    final response = await http.get(
      Uri.parse('$baseUrl/seller'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    return data.map((item) => Product.fromJson(item)).toList();
  }

  static Future<void> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create/sellers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }
  }
}
