import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lance_certo/models/user.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  static StompClient? _stompClient;
  static final String _socketUrl = 'ws://127.0.0.1:8080/ws';
  static final Map<String, StompUnsubscribe> _subscriptions = {};

  static String? _getAuthToken() {
    return User.token;
  }

  static String getAuctionBidsTopic(int auctionId) =>
      '/topic/bids/auctions/$auctionId';
  static String getAuctionStatusTopic(int auctionId) =>
      '/topic/auctions/$auctionId/status';

  static final Set<Function(Map<String, dynamic>)> _activeBidNotifiers = {};
  static final Set<Function(Map<String, dynamic>)> _activeStatusNotifiers = {};

  static void registerBidNotifier(Function(Map<String, dynamic>) notifier) {
    _activeBidNotifiers.add(notifier);
  }

  static void registerStatusNotifier(Function(Map<String, dynamic>) notifier) {
    _activeStatusNotifiers.add(notifier);
  }

  static void unregisterBidNotifier(Function(Map<String, dynamic>) notifier) {
    _activeBidNotifiers.remove(notifier);
  }

  static void unregisterStatusNotifier(
    Function(Map<String, dynamic>) notifier,
  ) {
    _activeStatusNotifiers.remove(notifier);
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
      headers: {'Authorization': 'Bearer ${_getAuthToken()}'},
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final Map<String, dynamic> message = json.decode(frame.body!);

          if (destination.contains('status')) {
            for (final notifier in _activeStatusNotifiers) {
              notifier(message);
            }

            final int? auctionId = int.tryParse(destination.split('/')[3]);
            final String destinationNewBid = getAuctionBidsTopic(auctionId!);

            unsubscribe(destination);
            unsubscribe(destinationNewBid);

            return;
          }

          for (final notifier in _activeBidNotifiers) {
            notifier(message);
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
