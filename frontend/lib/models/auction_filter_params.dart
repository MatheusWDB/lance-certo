import 'package:lance_certo/models/auction_status.dart';

class AuctionFilterParams {
  AuctionFilterParams({
    this.productName,
    this.sellerName,
    this.statuses,
    this.minInitialPrice,
    this.maxInitialPrice,
    this.minCurrentBid,
    this.maxCurrentBid,
  });

  String? productName;
  List<String>? productCategories;
  String? sellerName;
  List<AuctionStatus>? statuses;
  double? minInitialPrice;
  double? maxInitialPrice;
  double? minCurrentBid;
  double? maxCurrentBid;

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};

    if (productName != null) params['productName'] = productName;

    if (sellerName != null) params['sellerName'] = sellerName;

    if (statuses != null && statuses!.isNotEmpty) {
      params['statuses'] = statuses!.map((s) => s.name).join(',');
    }

    if (minCurrentBid != null) {
      params['minCurrentBid'] = minCurrentBid.toString();
    }

    if (maxCurrentBid != null) {
      params['maxCurrentBid'] = maxCurrentBid.toString();
    }

    if (minInitialPrice != null) {
      params['minInitialPrice'] = minInitialPrice.toString();
    }

    if (maxInitialPrice != null) {
      params['maxInitialPrice'] = maxInitialPrice.toString();
    }

    return params;
  }

  @override
  String toString() {
    return 'AuctionFilterParams{productName: $productName, statuses: $statuses, ...}';
  }
}
