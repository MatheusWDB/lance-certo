import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/models/user.dart';

class Auction {
  Auction({
    required this.startDateAndTime,
    required this.endDateAndTime,
    required this.initialPrice,
    required this.minimunBidIncrement,
    this.product,
    this.seller,
    this.status,
    this.id,
    this.currentBid,
    this.currentBidder,
    this.winner,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final Product? product;
  final User? seller;
  final DateTime startDateAndTime;
  final DateTime endDateAndTime;
  final double initialPrice;
  final double minimunBidIncrement;
  double? currentBid;
  User? currentBidder;
  AuctionStatus? status;
  User? winner;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['id'] as int?,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      seller: User.fromJson(json['product']['seller'] as Map<String, dynamic>),
      startDateAndTime: DateTime.parse(json['startDateAndTime'] as String),
      endDateAndTime: DateTime.parse(json['endDateAndTime'] as String),
      initialPrice: (json['initialPrice'] as num).toDouble(),
      minimunBidIncrement: (json['minimunBidIncrement'] as num).toDouble(),
      currentBid: (json['currentBid'] as num?)?.toDouble(),
      currentBidder: json['currentBidder'] != null
          ? User.fromJson(json['currentBidder'] as Map<String, dynamic>)
          : null,
      status: AuctionStatus.fromString(json['status'] as String),
      winner: json['winner'] != null
          ? User.fromJson(json['winner'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': product!.id,
    'startDateAndTime': startDateAndTime.toIso8601String(),
    'endDateAndTime': endDateAndTime.toIso8601String(),
    'initialPrice': initialPrice,
    'minimunBidIncrement': minimunBidIncrement,
  };

  @override
  String toString() {
    return 'Auction(\n'
        '  id: $id,\n'
        '  product: ${product?.toString() ?? 'N/A'},\n'
        '  seller: ${seller?.username ?? 'N/A'},\n'
        '  startDateAndTime: ${DateFormat('dd/MM/yyyy HH:mm').format(startDateAndTime)},\n'
        '  endDateAndTime: ${DateFormat('dd/MM/yyyy HH:mm').format(endDateAndTime)},\n'
        '  initialPrice: $initialPrice,\n'
        '  minimunBidIncrement: $minimunBidIncrement,\n'
        '  currentBid: ${currentBid ?? 'N/A'},\n'
        '  currentBidder: ${currentBidder?.username ?? 'N/A'},\n'
        '  status: ${status?.name ?? 'N/A'},\n'
        '  winner: ${winner?.username ?? 'N/A'},\n'
        '  createdAt: ${createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!) : 'N/A'},\n'
        '  updatedAt: ${updatedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt!) : 'N/A'},\n'
        ')';
  }
}
