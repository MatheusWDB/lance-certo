import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/services/bid_service.dart';

class BidCreationWidget extends StatefulWidget {
  const BidCreationWidget({
    required this.auction,
    required this.updateList,
    super.key,
  });

  final Auction auction;
  final Future<void> Function() updateList;

  @override
  State<BidCreationWidget> createState() => _BidCreationWidgetState();
}

class _BidCreationWidgetState extends State<BidCreationWidget> {
  late Auction auction;

  bool _isLoading = false;
  final TextEditingController _bidController = TextEditingController();

  String currencyFormat(double? number) {
    final value = number ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  void createBid() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bidValue = Bid(
        amount: double.parse(_bidController.text.replaceAll(',', '.')),
      );

      await BidService.createBid(auction.id!, bidValue);
      await widget.updateList();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _bidController.clear();
      });

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final String errorMessage = e.toString();
        final String cleanMessage = errorMessage.replaceFirst(
          'Exception: ',
          '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage, textAlign: TextAlign.center),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    auction = widget.auction;
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 500),
          backgroundColor: Colors.white,
          child: Column(
            spacing: 8.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text('Faça seu lance:', style: TextStyle(fontSize: 20.0)),
                  Text(
                    auction.product!.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(auction.product!.description),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                    color: const Color(0xFFEFF6FF),
                  ),
                  child: Column(
                    spacing: 16.0,
                    children: [
                      Column(
                        children: [
                          const Text('Lance atual:'),
                          Text(
                            currencyFormat(
                              auction.currentBid == 0
                                  ? auction.initialPrice
                                  : auction.currentBid!,
                            ),
                            style: const TextStyle(
                              fontSize: 36.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        spacing: 8.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seu Lance:', textAlign: TextAlign.start),
                          TextField(
                            controller: _bidController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              constraints: const BoxConstraints(maxWidth: 300.0),
                              labelText:
                                  'Mínimo: ${currencyFormat(auction.currentBid == 0 ? auction.initialPrice + auction.minimunBidIncrement : auction.currentBid! + auction.minimunBidIncrement)}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 60.0,
                          ),
                          backgroundColor: const Color.fromARGB(255, 22, 163, 74),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => createBid(),
                        child: const Text('Dar Lance'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading) ...[
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.4),
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
