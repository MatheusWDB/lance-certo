import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:lance_certo/mixins/validations_mixin.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/services/bid_service.dart';
import 'package:lance_certo/services/web_socket_service.dart';
import 'package:lance_certo/utils/currency_formatting.dart';
import 'package:lance_certo/utils/responsive.dart';
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

class _AuctionDetailsWidgetState extends State<AuctionDetailsWidget>
    with ValidationsMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bidController = TextEditingController();
  late Auction _auction;
  late Future<PaginatedResponse<Bid>> _bids;
  bool _isActive = true;
  bool _isLoading = false;
  String? _error;

  void _createBid() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bidValue = Bid(
        amount: double.parse(_bidController.text.replaceAll(',', '.')),
      );

      await BidService.createBid(_auction.id!, bidValue);

      final String auctionBidUpdateTopic = WebSocketService.getBidUpdateTopic(
        _auction.id!,
      );
      final String auctionStatusTopic = WebSocketService.getAuctionStatusTopic(
        _auction.id!,
      );

      WebSocketService.subscribe(auctionBidUpdateTopic);
      WebSocketService.subscribe(auctionStatusTopic);

      await _fetchAuctionById();
      _fetchBidsByAuction();

      setState(() {
        _bidController.text = '';
        _isLoading = false;
      });

      await widget.updateList!();
    } on FormatException {
      setState(() {
        _error = 'Formato inválido.';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao criar lance: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final String errorMessage = e.toString();
        String cleanMessage = errorMessage.replaceFirst(
          'Exception: Falha ao criar lance: ',
          '',
        );

        if (cleanMessage.contains('menor')) {
          cleanMessage = 'O lance não pode ser menor do quê o mínimo';
        }

        setState(() {
          _error = cleanMessage;
        });

        AlertInfo.show(
          context: context,
          text: cleanMessage,
          typeInfo: TypeInfo.error,
        );
      }
    }
  }

  void _fetchBidsByAuction() {
    try {
      _bids = BidService.fetchBidsByAuction(_auction.id!);
    } catch (e) {
      debugPrint('Erro ao buscar lances: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final String errorMessage = e.toString();
        final String cleanMessage = errorMessage.replaceFirst(
          'Exception: ',
          '',
        );

        AlertInfo.show(
          context: context,
          text: cleanMessage,
          typeInfo: TypeInfo.error,
        );
      }
    }
  }

  Future<void> _fetchAuctionById() async {
    try {
      _auction = await AuctionService.fetchAuctionById(_auction.id!);
    } catch (e) {
      debugPrint('Erro ao buscar leilão: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final String errorMessage = e.toString();
        final String cleanMessage = errorMessage.replaceFirst(
          'Exception: ',
          '',
        );

        AlertInfo.show(
          context: context,
          text: cleanMessage,
          typeInfo: TypeInfo.error,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _auction = widget.auction;
    _fetchBidsByAuction();

    if (_auction.status != AuctionStatus.ACTIVE ||
        _auction.seller!.id == User.currentUser!.id) {
      _isActive = false;
    }
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProductName = Responsive.valueForBreakpoints(
      context: context,
      xs: 24.0,
      sm: 32.0,
    );

    final heightImage = Responsive.valueForBreakpoints(
      context: context,
      xs: 150.0,
      sm: 200.0,
    );

    final fontSizeDescription = Responsive.valueForBreakpoints(
      context: context,
      xs: 15.0,
      sm: 18.0,
    );

    final fontSizeCurrentBid = Responsive.valueForBreakpoints(
      context: context,
      xs: 16.0,
      sm: 24.0,
    );

    final formPadding = Responsive.valueForBreakpoints(
      context: context,
      xs: 10.0,
      sm: 15.7,
    );

    final fontSizeHintText = Responsive.valueForBreakpoints(
      context: context,
      xs: 16.0,
      sm: 24.0,
    );

    final fonteSizeButtom = Responsive.valueForBreakpoints(
      context: context,
      xs: 16.0,
      sm: 18.0,
    );

    final paddingHorizontalButtom = Responsive.valueForBreakpoints(
      context: context,
      xs: 60.0,
    );

    final paddingVerticalButtom = Responsive.valueForBreakpoints(
      context: context,
      xs: 16.0,
      sm: 18.0,
    );

    final fontSizeBids = Responsive.valueForBreakpoints(
      context: context,
      xs: 18.0,
      sm: 24.0,
    );

    final heightContainerBids = Responsive.valueForBreakpoints(
      context: context,
      xs: 180.0,
      sm: 160.0,
    );

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              spacing: 12.0,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _auction.product!.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSizeProductName,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: heightImage,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8.0),
                    ),
                  ),
                  child: Image.network(
                    'https://pbs.twimg.com/media/FWWl7ftXwAYzv3X?format=png&name=medium',
                    fit: BoxFit.cover,
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
                      return const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      );
                    },
                  ),
                ),
                Text(
                  _auction.product!.description,
                  textAlign: TextAlign.justify,
                  maxLines: 2,
                  style: TextStyle(fontSize: fontSizeDescription),
                ),
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
                              spacing: 8.0,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text('Lance Atual:'),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6.7,
                                  ),
                                  child: Text(
                                    CurrencyFormatting.currencyFormat(
                                      _auction.currentBid,
                                    ),
                                    style: TextStyle(
                                      fontSize: fontSizeCurrentBid,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              spacing: 8.0,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text('Lance Mínimo:'),
                                TextFormField(
                                  key: _formKey,
                                  enabled: _isActive,
                                  controller: _bidController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(formPadding),
                                    errorText: _error,
                                    errorMaxLines: 2,
                                    labelText:
                                        CurrencyFormatting.currencyFormat(
                                          _auction.currentBid == 0
                                              ? _auction.initialPrice +
                                                    _auction.minimunBidIncrement
                                              : _auction.currentBid! +
                                                    _auction
                                                        .minimunBidIncrement,
                                        ),
                                    border: const OutlineInputBorder(),
                                    constraints: const BoxConstraints(
                                      maxWidth: 300.0,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: fontSizeHintText,
                                    ),
                                  ),
                                  validator: (value) => combine([
                                    () => isNotEmpty(value),
                                    () => isNumber(value!.replaceAll(',', '.')),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: paddingVerticalButtom,
                            horizontal: paddingHorizontalButtom,
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            22,
                            163,
                            74,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: TextStyle(
                            fontSize: fonteSizeButtom,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _isActive ? _createBid : null,

                        child: const Text('Dar Lance'),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Text('Tempo Restante:', textAlign: TextAlign.center),
                    AuctionTimerWidget(
                      endTime: _auction.endDateAndTime,
                      updateList: () async {
                        if (_isActive) {
                          setState(() {
                            _isActive = !_isActive;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const Divider(color: Colors.grey),
                Text(
                  'Histórico de Lances',
                  style: TextStyle(
                    fontSize: fontSizeBids,
                    fontWeight: FontWeight.bold,
                  ),
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
                  child: SizedBox(
                    height: heightContainerBids,
                    child: FutureBuilder<PaginatedResponse<Bid>>(
                      future: _bids,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
      ),
    );
  }
}
