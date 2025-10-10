import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/widgets/auction_details_widget.dart';
import 'package:lance_certo/widgets/auction_timer_widget.dart';

class DashboardListWidget extends StatefulWidget {
  final String activeMenu;
  final Object item;
  final Future<void> Function() updateList;

  const DashboardListWidget({
    required this.activeMenu,
    required this.item,
    required this.updateList,
    super.key,
  });

  @override
  State<DashboardListWidget> createState() => _DashboardListWidgetState();
}

class _DashboardListWidgetState extends State<DashboardListWidget> {
  late dynamic item;

  Color _colorCard() {
    if (widget.activeMenu == 'myAuctions') {
      if ((item as Auction).status == AuctionStatus.ACTIVE) {
        return const Color.fromARGB(255, 240, 253, 244);
      } else if ((item as Auction).status == AuctionStatus.PENDING) {
        return const Color.fromARGB(255, 255, 231, 209);
      } else {
        return const Color.fromARGB(255, 255, 227, 227);
      }
    }

    if (widget.activeMenu == 'closedAuctions') {
      return const Color.fromARGB(255, 243, 244, 246);
    }

    return const Color.fromARGB(255, 239, 246, 255);
  }

  String currencyFormat(double? number) {
    final value = number ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  Future<Auction> _fetchAuctionById(int auctionId) async {
    return AuctionService.fetchAuctionById(auctionId);
  }

  List<Widget> _rowContent() {
    late Widget timer;
    String text1 = '';
    String text2 = '';
    String text3 = '';
    String text4 = '';
    String text5 = '';
    String text6 = '';
    late Color colorText3;
    late Color colorText5;

    switch (widget.activeMenu) {
      case 'myBids':
        if (item.auction!.status == AuctionStatus.ACTIVE) {
          colorText3 = const Color.fromARGB(255, 29, 78, 216);
          colorText5 = const Color.fromARGB(255, 99, 159, 96);
          timer = AuctionTimerWidget(
            endTime: item.auction.endTime,
            updateList: () => widget.updateList(),
          );
          text1 = item.auction!.product!.name;
          text2 = 'Seu Lance: ';
          text3 = currencyFormat(item.amount);
          text4 = 'Tempo Restante: ';
          text6 = 'Ver Leilão';
        }

        break;
      case 'myAuctions':
        colorText3 = const Color.fromARGB(255, 21, 128, 61);

        if ((item as Auction).status == AuctionStatus.ACTIVE) {
          colorText5 = const Color.fromARGB(255, 99, 159, 96);
        } else if ((item as Auction).status == AuctionStatus.PENDING) {
          colorText5 = const Color.fromARGB(255, 235, 114, 1);
        } else {
          colorText5 = const Color.fromARGB(255, 185, 28, 28);
        }

        if (item.seller.id == User.currentUser!.id) {
          text1 = item.product!.name;
          text2 = 'Lance Atual: ';
          text3 = currencyFormat(item.currentBid);
          text4 = 'Status: ';
          text5 = item.status!.displayName;
          text6 = 'Gerenciar';
        }

        break;
      case 'closedAuctions':
        if (item.auction!.status! == AuctionStatus.CLOSED ||
            item.auction!.status! == AuctionStatus.CANCELLED) {
          text1 = item.auction!.product!.name;
          text2 = 'Seu Lance: ';
          text3 = currencyFormat(item.amount);
          text4 = 'Status: ';

          if (item.auction!.winner!.id == User.currentUser!.id) {
            text5 = 'Você Venceu!';
            colorText3 = const Color.fromARGB(255, 126, 34, 213);
            colorText5 = const Color.fromARGB(255, 126, 34, 213);
          } else if (item.auction!.status == AuctionStatus.CANCELLED) {
            text5 = 'Leilão Cancelado';
            colorText3 = const Color.fromARGB(255, 185, 28, 28);
            colorText5 = const Color.fromARGB(255, 185, 28, 28);
          } else {
            text5 = 'Você Perdeu!';
            colorText3 = const Color.fromARGB(255, 185, 28, 28);
            colorText5 = const Color.fromARGB(255, 185, 28, 28);
          }

          text6 = 'Detalhes do Leilão';
        }

        break;

      default:
        break;
    }

    return [
      Expanded(
        child: Column(
          spacing: 4.0,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text1,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                children: [
                  TextSpan(text: text2),
                  TextSpan(
                    text: text3,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorText3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (widget.activeMenu == 'myBids')
        Expanded(child: Row(children: [Text(text4), timer])),
      if (widget.activeMenu != 'myBids')
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: text4),
                TextSpan(
                  text: text5,
                  style: TextStyle(color: colorText5),
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
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            Auction auction;

            if (widget.activeMenu == 'myAuctions') {
              auction = item;
            } else {
              auction = await _fetchAuctionById((item as Bid).auction!.id!);
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
          child: Text(text6),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    if (widget.activeMenu == 'myAuctions') {
      item = widget.item as Auction;
      return;
    }

    item = widget.item as Bid;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.activeMenu == 'myBids' &&
            item.auction!.status != AuctionStatus.ACTIVE) ||
        (widget.activeMenu == 'myAuctions' &&
            item.seller.id != User.currentUser!.id) ||
        (widget.activeMenu == 'closedAuctions' &&
            (item.auction!.status != AuctionStatus.CLOSED &&
                item.auction!.status != AuctionStatus.CANCELLED))) {
      return const SizedBox.shrink();
    }
    return Card(
      color: _colorCard(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _rowContent(),
        ),
      ),
    );
  }
}
