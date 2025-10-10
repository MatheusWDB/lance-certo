import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/models/user.dart';

class Auction {
  Auction({
    required this.startTime,
    required this.endTime,
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
  final DateTime startTime;
  final DateTime endTime;
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
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
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
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'initialPrice': initialPrice,
    'minimunBidIncrement': minimunBidIncrement,
  };

  @override
  String toString() {
    return 'Auction(\n'
        '  id: $id,\n'
        '  product: ${product?.toString() ?? 'N/A'},\n' // Acessa o nome do produto (se não for null)
        '  seller: ${seller?.username ?? 'N/A'},\n' // Acessa o username do vendedor
        '  startTime: ${DateFormat('dd/MM/yyyy HH:mm').format(startTime)},\n'
        '  endTime: ${DateFormat('dd/MM/yyyy HH:mm').format(endTime)},\n'
        '  initialPrice: $initialPrice,\n'
        '  minimunBidIncrement: $minimunBidIncrement,\n'
        '  currentBid: ${currentBid ?? 'N/A'},\n' // Se currentBid for null, mostra 'N/A'
        '  currentBidder: ${currentBidder?.username ?? 'N/A'},\n'
        '  status: ${status?.name ?? 'N/A'},\n' // Acessa o nome do enum
        '  winner: ${winner?.username ?? 'N/A'},\n'
        '  createdAt: ${createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!) : 'N/A'},\n'
        '  updatedAt: ${updatedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt!) : 'N/A'},\n' // Se bids for null, mostra 0
        ')';
  }
}
