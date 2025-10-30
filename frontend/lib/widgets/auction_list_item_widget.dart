import 'package:flutter/material.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/utils/currency_formatting.dart';
import 'package:lance_certo/utils/responsive.dart';
import 'package:lance_certo/widgets/auction_details_widget.dart';
import 'package:lance_certo/widgets/auction_timer_widget.dart';

class AuctionListItemWidget extends StatefulWidget {
  const AuctionListItemWidget({
    required this.auction,
    required this.updateList,
    super.key,
  });

  final Auction auction;
  final Future<void> Function() updateList;

  @override
  State<AuctionListItemWidget> createState() => _AuctionListItemWidgetState();
}

class _AuctionListItemWidgetState extends State<AuctionListItemWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.auction.status == AuctionStatus.CLOSED) {
      return const SizedBox.shrink();
    }

    final containerHeigth = Responsive.valueForBreakpoints(
      context: context,
      xs: 227.0,
      md: 207.0,
    );

    final fontSizeCurrentBid = Responsive.valueForBreakpoints(
      context: context,
      xs: 18.0,
      md: 24.0,
    );

    return Card(
      color: Colors.white,
      shadowColor: widget.auction.seller!.id == User.currentUser!.id
          ? Colors.grey
          : const Color.fromARGB(255, 255, 231, 209),
      elevation: 3,
      child: Column(
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
          Container(
            padding: const EdgeInsets.all(14.0),
            height: containerHeigth,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.0,
              children: [
                Text(
                  widget.auction.product!.name,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.auction.product!.description,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lance Atual:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          CurrencyFormatting.currencyFormat(
                            widget.auction.currentBid,
                          ),
                          style: TextStyle(
                            color: Color.fromARGB(255, 29, 79, 218),
                            fontSize: fontSizeCurrentBid,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Tempo Restante:',
                          style: TextStyle(fontSize: 12),
                        ),
                        AuctionTimerWidget(
                          endTime: widget.auction.endDateAndTime,
                          updateList: () => widget.updateList(),
                        ),
                      ],
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.auction.seller!.id != User.currentUser!.id
                          ? Color.fromARGB(255, 59, 130, 246)
                          : Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16.0,
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
                            auction: widget.auction,
                            updateList: widget.updateList,
                          );
                        },
                      );
                    },
                    child: const Text('Ver Detalhes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
