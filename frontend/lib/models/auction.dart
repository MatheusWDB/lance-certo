import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/models/user.dart';

class Auction {
  Auction({
    required this.product,
    required this.startTime,
    required this.endTime,
    required this.initialPrice,
    required this.minimunBidIncrement,
    this.auctionId,
    this.currentBid,
    this.currentBidder,
    this.status,
    this.winner,
    this.createdAt,
    this.updatedAt,
  });

  final int? auctionId;
  final Product product;
  final DateTime startTime;
  final DateTime endTime;
  final double initialPrice;
  final double minimunBidIncrement;
  final double? currentBid;
  final User? currentBidder;
  final AuctionStatus? status;
  final User? winner;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      auctionId: json['auctionId'],
      product: json['product'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      initialPrice: json['initialPrice'],
      minimunBidIncrement: json['minimunBidIncrement'],
      currentBid: json['currentBid'],
      currentBidder: json['currentBidder'],
      status: json['status'],
      winner: json['winner'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': product.productId,
    'startTime': startTime,
    'endTime': endTime,
    'initialPrice': initialPrice,
    'minimunBidIncrement': minimunBidIncrement,
  };
}
