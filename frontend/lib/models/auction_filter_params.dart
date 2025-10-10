import 'package:lance_certo/models/auction_status.dart';

class AuctionFilterParams {
  AuctionFilterParams({
    this.productName,
    this.productCategories,
    this.sellerName,
    this.winnerName,
    this.statuses,
    this.minInitialPrice,
    this.maxInitialPrice,
    this.minCurrentBid,
    this.maxCurrentBid,
    this.minStartTime,
    this.maxStartTime,
    this.minEndTime,
    this.maxEndTime,
  });

  String? productName;
  List<String>? productCategories;
  String? sellerName;
  String? winnerName;
  List<AuctionStatus>? statuses;
  int? minInitialPrice;
  int? maxInitialPrice;
  int? minCurrentBid;
  int? maxCurrentBid;
  DateTime? minStartTime;
  DateTime? maxStartTime;
  DateTime? minEndTime;
  DateTime? maxEndTime;

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};

    if (productName != null) params['productName'] = productName;
    if (productCategories != null && productCategories!.isNotEmpty) {
      params['productCategories'] = productCategories!.join(
        ',',
      );
    }
    if (statuses != null && statuses!.isNotEmpty) {
      params['statuses'] = statuses!
          .map((s) => s.name)
          .join(',');
    }
    if (minInitialPrice != null) {
      params['minInitialPrice'] = minInitialPrice.toString();
    }
    if (maxInitialPrice != null) {
      params['maxInitialPrice'] = maxInitialPrice.toString();
    }
    if (minStartTime != null) {
      params['minStartTime'] = minStartTime!.toIso8601String();
    }
    if (maxStartTime != null) {
      params['maxStartTime'] = maxStartTime!.toIso8601String();
    }
    if (minEndTime != null) {
      params['minEndTime'] = minEndTime!.toIso8601String();
    }
    if (maxEndTime != null) {
      params['maxEndTime'] = maxEndTime!.toIso8601String();
    }

    return params;
  }

  @override
  String toString() {
    return 'AuctionFilterParams{productName: $productName, statuses: $statuses, ...}';
  }
}
