import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/models/user.dart';

class BidService {
  static String address = dotenv.get('URL');
  static  String baseUrl = 'http://$address/api/bids';

  static String? _getAuthToken() {
    return User.token;
  }

  static Future<void> createBid(int auctionId, Bid bid) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auctions/$auctionId/bidder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
      body: json.encode(bid.toJson()),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }
  }

  static Future<PaginatedResponse<Bid>> fetchBidsByBidder() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bidder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    return PaginatedResponse.fromJson(data, (json) => Bid.fromJson(json));
  }

  static Future<PaginatedResponse<Bid>> fetchBidsByAuction(
    int auctionId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auctions/$auctionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getAuthToken()}',
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro de autenticação desconhecido');
    }

    return PaginatedResponse.fromJson(data, (json) => Bid.fromJson(json));
  }
}
