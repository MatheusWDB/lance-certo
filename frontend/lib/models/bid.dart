import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/user.dart';

class Bid {
  Bid({
    required this.amount,
    this.id,
    this.auction,
    this.bidder,
    this.createdAt,
  });

  final int? id;
  final Auction? auction;
  final double amount;
  final User? bidder;
  final DateTime? createdAt;

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'] as int?,
      auction: json['auction'] != null
          ? Auction.fromJson(json['auction'] as Map<String, dynamic>)
          : null,
      amount: (json['amount'] as num).toDouble(),
      bidder: json['bidder'] != null
          ? User.fromJson(json['bidder'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'amount': amount};
}
