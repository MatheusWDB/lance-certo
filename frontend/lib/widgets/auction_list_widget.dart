import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/widgets/auction_details_widget.dart';
import 'package:lance_certo/widgets/auction_timer_widget.dart';
import 'package:lance_certo/widgets/bid_creation_widget.dart';

class AuctionListWidget extends StatefulWidget {
  const AuctionListWidget({
    required this.auction,
    required this.updateList,
    super.key,
  });

  final Auction auction;
  final Future<void> Function() updateList;

  @override
  State<AuctionListWidget> createState() => _AuctionListWidgetState();
}

class _AuctionListWidgetState extends State<AuctionListWidget> {
  late Auction auction;

  String currencyFormat(double? number) {
    final value = number ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  void initState() {
    super.initState();
    auction = widget.auction;
  }

  @override
  Widget build(BuildContext context) {
    if (auction.status == AuctionStatus.CLOSED) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey,
      elevation: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 140.0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8.0),
              ),
              child: Image.network(
                'https://pbs.twimg.com/media/FWWl7ftXwAYzv3X?format=png&name=medium',
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red, size: 50);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.0,
              children: [
                Text(
                  auction.product!.name,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  auction.product!.description,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lance Atual:', style: TextStyle(fontSize: 12)),
                        Text(
                          currencyFormat(auction.currentBid),

                          style: const TextStyle(
                            color: Color.fromARGB(255, 29, 79, 218),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Tempo Restante:', style: TextStyle(fontSize: 12)),
                        AuctionTimerWidget(
                          endTime: auction.endTime,
                          updateList: () => widget.updateList(),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 59, 130, 246),
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return AuctionDetailsWidget(
                              auction: auction,
                              updateList: widget.updateList,
                            );
                          },
                        );
                      },
                      child: const Text('Ver Detalhes'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 22, 163, 74),
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return BidCreationWidget(
                              auction: auction,
                              updateList: () => widget.updateList(),
                            );
                          },
                        );
                      },
                      child: const Text('Dar Lance'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
