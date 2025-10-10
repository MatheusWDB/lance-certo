import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/services/bid_service.dart';
import 'package:lance_certo/widgets/auction_timer_widget.dart';
import 'package:lance_certo/widgets/bid_list_widget.dart';

class AuctionDetailsWidget extends StatefulWidget {
  const AuctionDetailsWidget({
    required this.auction,
    this.updateList,
    super.key,
  });

  final Auction auction;
  final Future<void> Function()? updateList;

  @override
  State<AuctionDetailsWidget> createState() => _AuctionDetailsWidgetState();
}

class _AuctionDetailsWidgetState extends State<AuctionDetailsWidget> {
  late Auction _auction;
  late Future<PaginatedResponse<Bid>> _bids;

  bool _isLoading = false;
  bool isActive = true;
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

      await BidService.createBid(_auction.id!, bidValue);

      await _fetchAuctionById();
      _fetchBidsByAuction();

      setState(() {
        _bidController.text = '';
        _isLoading = false;
      });

      await widget.updateList!();
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

  void _fetchBidsByAuction() {
    _bids = BidService.fetchBidsByAuction(_auction.id!);
  }

  Future<void> _fetchAuctionById() async {
    _auction = await AuctionService.fetchAuctionById(_auction.id!);
  }

  @override
  void initState() {
    super.initState();
    _auction = widget.auction;
    _fetchBidsByAuction();
    if (_auction.status != AuctionStatus.ACTIVE) {
      isActive = false;
    }
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
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            spacing: 12.0,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _auction.product!.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                ),
                height: 200.0,
                child: Image.network(
                  'https://pbs.twimg.com/media/FWWl7ftXwAYzv3X?format=png&name=medium',
                  fit: BoxFit.cover,
                  height: 200,
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
              SizedBox(
                height: 56.0,
                child: Text(
                  _auction.product!.description,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
              //Text(auction.product!.category),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    width: 0.5,
                    color: const Color.fromARGB(45, 0, 0, 0),
                  ),
                  color: const Color.fromARGB(255, 249, 250, 251),
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Lance Atual:', textAlign: TextAlign.center),
                              Text(
                                currencyFormat(_auction.currentBid),
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            spacing: 8.0,
                            children: [
                              const Text('Seu Lance:', textAlign: TextAlign.start),
                              TextField(
                                enabled: isActive,
                                controller: _bidController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  constraints: const BoxConstraints(maxWidth: 300.0),
                                  labelStyle: const TextStyle(color: Colors.grey),
                                  labelText:
                                      'Mínimo: ${currencyFormat(_auction.currentBid == 0 ? _auction.initialPrice + _auction.minimunBidIncrement : _auction.currentBid! + _auction.minimunBidIncrement)}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ],
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
                      onPressed: isActive ? createBid : null,

                      child: const Text('Dar Lance'),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text('Tempo Restante:', textAlign: TextAlign.center),
                  AuctionTimerWidget(
                    endTime: _auction.endTime,
                    updateList: () async {
                      if (isActive) {
                        setState(() {
                          isActive = !isActive;
                        });
                      }
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              const Text(
                'Histórico de Lances',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    width: 0.5,
                    color: const Color.fromARGB(45, 0, 0, 0),
                  ),
                  color: const Color.fromARGB(255, 246, 247, 248),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 230.0),
                  child: FutureBuilder<PaginatedResponse<Bid>>(
                    future: _bids,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        debugPrint('Erro: ${snapshot.error}');
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.content.isEmpty) {
                        return const Center(
                          child: Text('Nenhum lance encontrado.'),
                        );
                      } else {
                        final paginatedBids = snapshot.data!;

                        final List<Bid> bids = paginatedBids.content
                            .map((bidDynamic) => bidDynamic as Bid)
                            .toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: bids.length,
                          itemBuilder: (context, index) {
                            final bid = bids[index];

                            return BidListWidget(bid: bid);
                          },
                        );
                      }
                    },
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
