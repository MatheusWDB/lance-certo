import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_filter_params.dart';
import 'package:lance_certo/models/pageable.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/models/user.dart';

class AuctionService {
  static const String baseUrl = 'http://127.0.0.1:8080/api/auctions';

  static String token = User.currentUser!.token!;

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

    final Map<String, String> finalQueryParams = queryParams.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      }
      return MapEntry(key, value.toString());
    }).cast<String, String>();

    final uri = Uri.http('127.0.0.1:8080', '/api/auctions', finalQueryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      return PaginatedResponse.fromJson(
        responseBody,
        (json) => Auction.fromJson(json),
      );
    } else {
      throw Exception(
        'Falha ao carregar leilões: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<void> createAuctions(Map<String, dynamic> controller) async {
    final auction = controller;

    final response = await http.post(
      Uri.parse('$baseUrl/create/sellers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(auction),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Falha ao criar leilão: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<PaginatedResponse<Auction>> fetchAuctionsBySeller() async {
    final response = await http.get(
      Uri.parse('$baseUrl/seller'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      return PaginatedResponse.fromJson(
        responseBody,
        (json) => Auction.fromJson(json),
      );
    } else {
      throw Exception(
        'Falha ao carregar leilões do vendedor: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<Auction> fetchAuctionById(int auctionId) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8080/api/auction/$auctionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      return Auction.fromJson(responseBody);
    } else {
      throw Exception(
        'Falha ao carregar leilões do vendedor: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
