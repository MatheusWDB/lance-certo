import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_filter_params.dart';
import 'package:lance_certo/models/pageable.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/models/user.dart';

class AuctionService {
  static String address = dotenv.get('URL');
  static String baseUrl = 'http://$address/api/auctions';

  static String? _getAuthToken() {
    return User.token;
  }

  static Future<PaginatedResponse<Auction>> fetchAllAuctions(
    Pageable pageable,
    AuctionFilterParams? filters,
  ) async {
    final Map<String, dynamic> queryParams = {};

    queryParams['page'] = pageable.page.toString();
    queryParams['size'] = pageable.size.toString();
    if (pageable.sort != null && pageable.sort!.isNotEmpty) {
      queryParams['sort'] = pageable.sort!;
    }

    if (filters != null) {
      queryParams.addAll(filters.toQueryParams());
    }
    final List<String> url = baseUrl.split('/');
    final uri = Uri.http(url[2], '${url[3]}/${url[4]}', queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    return PaginatedResponse.fromJson(data, (json) => Auction.fromJson(json));
  }

  static Future<void> createAuctions(Map<String, dynamic> controller) async {
    final auction = controller;

    final response = await http.post(
      Uri.parse('$baseUrl/create/sellers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
      body: jsonEncode(auction),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }
  }

  static Future<PaginatedResponse<Auction>> fetchAuctionsBySeller() async {
    final response = await http.get(
      Uri.parse('$baseUrl/seller'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    return PaginatedResponse.fromJson(data, (json) => Auction.fromJson(json));
  }

  static Future<Auction> fetchAuctionById(int auctionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$auctionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    return Auction.fromJson(data);
  }
}
