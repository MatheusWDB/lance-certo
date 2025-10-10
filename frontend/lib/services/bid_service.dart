import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/models/user.dart';

class BidService {
  static const String baseUrl = 'http://127.0.0.1:8080/api/bids';

  static String token = User.currentUser!.token!;

  static Future<void> createBid(
    int auctionId,
    Bid bid,
  ) async {

    final response = await http.post(
      Uri.parse('$baseUrl/auctions/$auctionId/bidder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(bid.toJson()),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(
        'Falha ao criar lance: ${data['message']}',
      );
    }
  }

  static Future<PaginatedResponse<Bid>> fetchBidsByBidder() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bidder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      return PaginatedResponse.fromJson(
        responseBody,
        (json) => Bid.fromJson(json),
      );
    } else {
      throw Exception(
        'Falha ao carregar lances: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<PaginatedResponse<Bid>> fetchBidsByAuction(int auctionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auctions/$auctionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      return PaginatedResponse.fromJson(
        responseBody,
        (json) => Bid.fromJson(json),
      );
    } else {
      throw Exception(
        'Falha ao carregar lances: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
