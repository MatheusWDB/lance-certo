import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/utils/currency_formatting.dart';
import 'package:lance_certo/utils/responsive.dart';

class BidListWidget extends StatefulWidget {
  const BidListWidget({required this.bid, super.key});

  final Bid bid;

  @override
  State<BidListWidget> createState() => _BidListWidgetState();
}

class _BidListWidgetState extends State<BidListWidget> {
  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive.valueForBreakpoints(context: context, xs: 16.0);

    return Card(
      color: const Color.fromARGB(255, 243, 244, 246),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.bid.bidder!.name!,
                maxLines: 2,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
            Expanded(
              child: Text(
                CurrencyFormatting.currencyFormat(widget.bid.amount),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 21, 128, 61),
                ),
              ),
            ),
            Expanded(
              child: Text(
                DateFormat('HH:mm:ss').format(widget.bid.createdAt!),
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
