import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction.dart';
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

    final String text =
        'Lance Superado! O novo valor para ${bidResponse.auction!.product!.name} é ${currencyFormat(bidResponse.auction!.currentBid)}. Dê um lance maior AGORA!';

    _showAlert(text, type: TypeInfo.warning);
    debugPrint('Lance atualizado');
  }

  void onStatusUpdate(Map<String, dynamic> message) {
    final Auction auctionResponse = Auction.fromJson(message);

    final String text = auctionResponse.winner!.name == User.currentUser!.name
        ? '🎉 Você Venceu! Arrematou ${auctionResponse.product!.name} por ${currencyFormat(auctionResponse.currentBid)}. Prossiga para pagamento.'
        : 'Não foi desta vez. O leilão ${auctionResponse.product!.name} foi encerrado. Lance final: ${currencyFormat(auctionResponse.currentBid)}. Tente outro!';

    final TypeInfo type = auctionResponse.winner!.name == User.currentUser!.name
        ? TypeInfo.success
        : TypeInfo.info;

    _showAlert(text, type: type);
    debugPrint('Status atualizado');
  }
}
