import 'package:lance_certo/models/user.dart';

class Bid {
  Bid({
    required this.amount,
    this.bidId,
    this.auction,
    this.bidder,
    this.createdAt,
  });

  final int? bidId;
  final String? auction;
  final double amount;
  final User? bidder;
  final DateTime? createdAt;

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      bidId: json['id'],
      auction: json['auction'],
      bidder: json['bidder'],
      amount: json['amount'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {'amount': amount};
}
