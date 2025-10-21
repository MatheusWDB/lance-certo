import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/user.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  static StompClient? _stompClient;
  static final String _socketUrl = 'ws://127.0.0.1:8080/ws';
  static final Map<String, StompUnsubscribe> _subscriptions = {};

  static String? _getAuthToken() {
    return User.token;
  }

  static String getBidUpdateTopic(int auctionId) =>
      '/topic/auction/$auctionId/bids';

  static String getAuctionStatusTopic(int auctionId) =>
      '/topic/auction/$auctionId/status';

  static String getSellerBidTopic(int sellerId) =>
      '/user/topic/seller/$sellerId/bids';

  static String getSellerStatusTopic(int sellerId) =>
      '/user/topic/seller/$sellerId/auction/status';

  static late Function(Map<String, dynamic>) _activeBidNotifiers;
  static late Function(Map<String, dynamic>) _activeStatusNotifiers;
  static late Function(Map<String, dynamic>) _activeBidNotifiersForSellers;
  static late Function(Map<String, dynamic>) _activeStatusNotifiersForSellers;

  static void registerBidNotifier(Function(Map<String, dynamic>) notifier) {
    _activeBidNotifiers = notifier;
    debugPrint('WebSocketService: Registro no BidNotifier.');
  }

  static void registerStatusNotifier(Function(Map<String, dynamic>) notifier) {
    _activeStatusNotifiers = notifier;
    debugPrint('WebSocketService: Registro no StatusNotifier.');
  }

  static void registerBidNotifierForSellers(
    Function(Map<String, dynamic>) notifier,
  ) {
    _activeBidNotifiersForSellers = notifier;
    debugPrint('WebSocketService: Registro no BidNotifierForSellers.');
  }

  static void registerStatusNotifierForSellers(
    Function(Map<String, dynamic>) notifier,
  ) {
    _activeStatusNotifiersForSellers = notifier;
    debugPrint('WebSocketService: Registro no StatusNotifierForSellers.');
  }

  static void onConnect(StompFrame frame) {
    debugPrint('WebSocketService: Conectado ao STOMP!');
  }

  static void onDisconnect(StompFrame frame) {
    debugPrint('WebSocketService: Desconectado do STOMP!');
    _subscriptions.clear();
  }

  static void onError(StompFrame frame) {
    debugPrint('WebSocketService: Erro STOMP: ${frame.body}');
  }

  static void connect() {
    if (_stompClient != null && _stompClient!.connected) {
      debugPrint('WebSocketService: Já conectado.');
      return;
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: _socketUrl,
        onConnect: onConnect,
        onDisconnect: onDisconnect,
        onWebSocketError: (dynamic error) =>
            debugPrint('WebSocketService: Erro WebSocket: ${error.toString()}'),
        onStompError: onError,
        beforeConnect: () async {
          debugPrint('WebSocketService: Tentando conectar...');
        },
        stompConnectHeaders: {'Authorization': 'Bearer ${_getAuthToken()}'},
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  static void disconnect() {
    if (_stompClient != null && _stompClient!.connected) {
      _subscriptions.forEach((destination, unsubscribeFunction) {
        unsubscribeFunction();
      });
      _subscriptions.clear();

      _stompClient!.deactivate();
      _stompClient = null;

      debugPrint('WebSocketService: Desconectado com sucesso.');
    } else {
      debugPrint('WebSocketService: Cliente STOMP não está conectado.');
    }
  }

  static void subscribe(String destination) {
    if (_stompClient == null || !_stompClient!.connected) {
      debugPrint(
        'WebSocketService: Não conectado para se inscrever. Tentando reconectar...',
      );
      connect();
      return;
    }

    if (_subscriptions.containsKey(destination)) {
      debugPrint('WebSocketService: Já inscrito no tópico: $destination');
      return;
    }

    final StompUnsubscribe unsubscribeFunctionNewBids = _stompClient!.subscribe(
      destination: destination,
      headers: {'id': destination},
      callback: (StompFrame frame) {
        if (frame.body != null) {
          debugPrint('WebSocketService.subscribe: Início do callback');
          final Map<String, dynamic> message = json.decode(frame.body!);
          final bool isBidTopic = destination.contains('bids');
          final bool isSellerTopic = destination.contains('seller');

          if (isBidTopic) {
            final notifier = isSellerTopic
                ? _activeBidNotifiersForSellers
                : _activeBidNotifiers;
            notifier(message);
            return;
          }

          final notifier = isSellerTopic
              ? _activeStatusNotifiersForSellers
              : _activeStatusNotifiers;
          notifier(message);

          final String associatedBidTopic;

          if (isSellerTopic) {
            final int? sellerId = int.tryParse(destination.split('/')[4]);
            if (sellerId == null) {
              debugPrint(
                'WebSocketService: Erro ao parsear Seller ID para desinscrição.',
              );
              return;
            }

            associatedBidTopic = getSellerBidTopic(sellerId);
          } else {
            final int? auctionId = int.tryParse(destination.split('/')[3]);
            if (auctionId == null) {
              debugPrint(
                'WebSocketService: Erro ao parsear Auction ID para desinscrição.',
              );
              return;
            }

            associatedBidTopic = getBidUpdateTopic(auctionId);
          }

          if (message['status'] == AuctionStatus.CLOSED || message['status'] == AuctionStatus.CANCELLED) {
            unsubscribe(associatedBidTopic);
            unsubscribe(destination);
          }
        }
      },
    );

    _subscriptions[destination] = unsubscribeFunctionNewBids;

    debugPrint('WebSocketService: Inscrito no tópico: $destination');
  }

  static void unsubscribe(String destination) {
    if (_stompClient != null && _stompClient!.connected) {
      _subscriptions[destination]!();
      _subscriptions.remove(destination);
      debugPrint('WebSocketService: Desinscrito do tópico: $destination');
    }
  }
}
