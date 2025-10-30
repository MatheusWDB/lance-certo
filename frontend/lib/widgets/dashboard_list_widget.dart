import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/utils/currency_formatting.dart';
import 'package:lance_certo/utils/responsive.dart';
import 'package:lance_certo/widgets/auction_details_widget.dart';
import 'package:lance_certo/widgets/auction_timer_widget.dart';

class DashboardListWidget extends StatefulWidget {
  const DashboardListWidget({
    required this.activeMenu,
    required this.item,
    required this.updateList,
    super.key,
  });

  final int activeMenu;
  final Object item;
  final Future<void> Function() updateList;

  @override
  State<DashboardListWidget> createState() => _DashboardListWidgetState();
}

class _DashboardListWidgetState extends State<DashboardListWidget> {
  late dynamic _item;

  Color _colorCard() {
    if (widget.activeMenu == 1) {
      if ((_item as Auction).status == AuctionStatus.ACTIVE) {
        return const Color.fromARGB(255, 240, 253, 244);
      } else if ((_item as Auction).status == AuctionStatus.PENDING) {
        return const Color.fromARGB(255, 255, 231, 209);
      } else {
        return const Color.fromARGB(255, 255, 227, 227);
      }
    }

    if (widget.activeMenu == 2) {
      return const Color.fromARGB(255, 243, 244, 246);
    }

    return const Color.fromARGB(255, 239, 246, 255);
  }

  Future<Auction> _fetchAuctionById(int auctionId) {
    return AuctionService.fetchAuctionById(auctionId);
  }

  List<Widget> _rowContent() {
    final String productName = widget.activeMenu != 1
        ? _item.auction!.product!.name
        : _item.product!.name;
    final String bidLabel = widget.activeMenu != 1
        ? 'Seu Lance: '
        : 'Lance Atual: ';
    final String bid = widget.activeMenu != 1
        ? CurrencyFormatting.currencyFormat(_item.amount)
        : CurrencyFormatting.currencyFormat(_item.currentBid);
    final String statusLabel = widget.activeMenu != 0
        ? 'Status: '
        : 'Tempo Restante: ';
    String status = widget.activeMenu == 1 ? _item.status!.displayName : '';
    final String textButtom = widget.activeMenu != 1
        ? 'Gerenciar'
        : 'Ver Leilão';
    late Color colorBid;
    late Color colorStatus;

    switch (widget.activeMenu) {
      case 0:
        if (_item.auction!.status == AuctionStatus.ACTIVE) {
          colorBid = const Color.fromARGB(255, 29, 78, 216);
          colorStatus = const Color.fromARGB(255, 99, 159, 96);
        }
        break;

      case 1:
        colorBid = const Color.fromARGB(255, 21, 128, 61);

        if ((_item as Auction).status == AuctionStatus.ACTIVE) {
          colorStatus = const Color.fromARGB(255, 99, 159, 96);
        } else if ((_item as Auction).status == AuctionStatus.PENDING) {
          colorStatus = const Color.fromARGB(255, 235, 114, 1);
        } else {
          colorStatus = const Color.fromARGB(255, 185, 28, 28);
        }
        break;

      case 2:
        if (_item.auction!.status! == AuctionStatus.CLOSED ||
            _item.auction!.status! == AuctionStatus.CANCELLED) {
          if (_item.auction!.winner!.id == User.currentUser!.id) {
            status = 'Você Venceu!';
            colorBid = const Color.fromARGB(255, 126, 34, 213);
            colorStatus = const Color.fromARGB(255, 126, 34, 213);
          } else if (_item.auction!.status == AuctionStatus.CANCELLED) {
            status = 'Leilão Cancelado';
            colorBid = const Color.fromARGB(255, 185, 28, 28);
            colorStatus = const Color.fromARGB(255, 185, 28, 28);
          } else {
            status = 'Você Perdeu!';
            colorBid = const Color.fromARGB(255, 185, 28, 28);
            colorStatus = const Color.fromARGB(255, 185, 28, 28);
          }
        }
        break;

      default:
        break;
    }

    final fontSizeProductName = Responsive.valueForBreakpoints(
      context: context,
      xs: 16.0,
    );

    return [
      if (Responsive.isExtraSmall(context)) ...[
        Expanded(
          child: Column(
            spacing: 8.0,
            children: [
              Text(
                productName,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: fontSizeProductName,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(bidLabel, style: TextStyle()),
                      Text(
                        bid,
                        style: TextStyle(
                          fontSize: fontSizeProductName,
                          fontWeight: FontWeight.w600,
                          color: colorBid,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(statusLabel, style: TextStyle()),
                      if (widget.activeMenu == 0) ...[
                        AuctionTimerWidget(
                          endTime: _item.auction.endDateAndTime,
                          updateList: () => widget.updateList(),
                        ),
                      ] else ...[
                        Text(status, style: TextStyle(color: colorStatus)),
                      ],
                    ],
                  ),
                ],
              ),
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
                onPressed: () async {
                  late Auction auction;

                  if (widget.activeMenu == 1) {
                    auction = _item;
                  } else {
                    try {
                      auction = await _fetchAuctionById(
                        (_item as Bid).auction!.id!,
                      );
                    } catch (e) {
                      debugPrint('Erro ao buscar leilão: $e');
                      if (mounted) {
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

                  if (!mounted) return;

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
                child: Text(textButtom, style: TextStyle()),
              ),
            ],
          ),
        ),
      ] else ...[
        Expanded(
          child: Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                productName,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: fontSizeProductName,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(text: bidLabel, style: TextStyle()),
                    TextSpan(
                      text: bid,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorBid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.activeMenu == 0
              ? Column(
                  children: [
                    Text(statusLabel, style: TextStyle()),
                    AuctionTimerWidget(
                      endTime: _item.auction.endDateAndTime,
                      updateList: () => widget.updateList(),
                    ),
                  ],
                )
              : RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: statusLabel, style: TextStyle()),
                      TextSpan(
                        text: status,
                        style: TextStyle(color: colorStatus),
                      ),
                    ],
                  ),
                ),
        ),
        Flexible(
          child: ElevatedButton(
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
            onPressed: () async {
              late Auction auction;

              if (widget.activeMenu == 1) {
                auction = _item;
              } else {
                try {
                  auction = await _fetchAuctionById((_item as Bid).auction!.id!);
                } catch (e) {
                  debugPrint('Erro ao buscar leilão: $e');
                  if (mounted) {
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

              if (!mounted) return;

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
            child: Text(textButtom, style: TextStyle()),
          ),
        ),
      ],
    ];
  }

  @override
  void initState() {
    super.initState();

    if (widget.activeMenu == 1) {
      _item = widget.item as Auction;
      return;
    }

    _item = widget.item as Bid;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.activeMenu == 0 &&
            _item.auction!.status != AuctionStatus.ACTIVE) ||
        (widget.activeMenu == 1 && _item.seller.id != User.currentUser!.id) ||
        (widget.activeMenu == 2 &&
            (_item.auction!.status != AuctionStatus.CLOSED &&
                _item.auction!.status != AuctionStatus.CANCELLED))) {
      return const SizedBox.shrink();
    }

    return Card(
      color: _colorCard(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _rowContent(),
        ),
      ),
    );
  }
}
