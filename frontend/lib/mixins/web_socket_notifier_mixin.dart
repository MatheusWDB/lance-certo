import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/models/user.dart';

mixin WebSocketNotifierMixin<T extends StatefulWidget> on State<T> {
  void _showAlert(String text, {TypeInfo type = TypeInfo.info}) {
    if (mounted) {
      AlertInfo.show(context: context, text: text, typeInfo: type, duration: 5);
    }
  }

  String currencyFormat(double? number) {
    final value = number ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  void onBidUpdate(Map<String, dynamic> message) {
    final Bid bidResponse = Bid.fromJson(message);
    final String productName = bidResponse.auction!.product!.name;
    final String newBidAmount = currencyFormat(bidResponse.auction!.currentBid);

    final String text =
        'Lance Superado! O novo valor para "$productName" é de: $newBidAmount. Dê um lance maior AGORA!';

    _showAlert(text, type: TypeInfo.warning);
    debugPrint('Lance atualizado');
  }

  void onStatusUpdate(Map<String, dynamic> message) {
    final Auction auctionResponse = Auction.fromJson(message);
    final String productName = auctionResponse.product!.name;
    final String newBidAmount = currencyFormat(auctionResponse.currentBid);

    final String text = auctionResponse.winner!.name == User.currentUser!.name
        ? '🎉 Você Venceu! Arrematou "$productName" por $newBidAmount. Prossiga para pagamento.'
        : 'Não foi desta vez. O leilão "$productName" foi encerrado. Lance final: $newBidAmount. Tente outro!';

    final TypeInfo type = auctionResponse.winner!.name == User.currentUser!.name
        ? TypeInfo.success
        : TypeInfo.info;

    _showAlert(text, type: type);
    debugPrint('Status atualizado');
  }

  void onSellerBidUpdate(Map<String, dynamic> message) {
    final Bid bidResponse = Bid.fromJson(message);
    final String productName = bidResponse.auction!.product!.name;
    final String newBidAmount = currencyFormat(bidResponse.auction!.currentBid);

    final String text =
        '💰 Venda em Andamento! O leilão do produto "$productName" acaba de receber um novo lance: $newBidAmount.';

    _showAlert(text, type: TypeInfo.success);
    debugPrint('Novo lance recebido no leilão do vendedor.');
  }

  void onSellerStatusUpdate(Map<String, dynamic> message) {
    final Auction auctionResponse = Auction.fromJson(message);
    final String productName = auctionResponse.product!.name;
    final AuctionStatus newStatus = auctionResponse.status!;

    String statusText = '';
    TypeInfo type = TypeInfo.info;

    switch (newStatus) {
      case AuctionStatus.ACTIVE:
        statusText =
            '✅ Seu leilão "$productName" está ATIVO! Pronto para receber lances?!';
        type = TypeInfo.success;
        break;
      case AuctionStatus.CLOSED:
        if (auctionResponse.winner != null) {
          final finalBid = currencyFormat(auctionResponse.currentBid);
          statusText =
              '🎉 Leilão ENCERRADO! O produto "$productName" foi vendido por $finalBid.';
          type = TypeInfo.success;
        } else {
          statusText =
              '❌ Leilão ENCERRADO! Infelizmente o produto "$productName" não recebeu lances válidos.';
          type = TypeInfo.error;
        }
        break;
      default:
        statusText = 'ℹ️ Status de "$productName" atualizado para: $newStatus.';
        break;
    }

    _showAlert(statusText, type: type);
    debugPrint('Status do leilão do vendedor atualizado.');
  }
}
