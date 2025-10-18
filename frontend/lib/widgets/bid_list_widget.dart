import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/bid.dart';

class BidListWidget extends StatefulWidget {
  const BidListWidget({required this.bid, super.key});

  final Bid bid;

  @override
  State<BidListWidget> createState() => _BidListWidgetState();
}

class _BidListWidgetState extends State<BidListWidget> {
  String currencyFormat(double? number) {
    final value = number ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 243, 244, 246),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${widget.bid.bidder!.name!}:',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            Expanded(
              child: Text(
                currencyFormat(widget.bid.amount),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 21, 128, 61),
                ),
              ),
            ),
            Expanded(
              child: Text(
                DateFormat('HH:mm:ss').format(widget.bid.createdAt!),
                textAlign: TextAlign.end,
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
