import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:trading_instruments/data/service/finn_hub_socket_service.dart';
import 'package:trading_instruments/data/service/finn_hub_symbol_api_service.dart';
import 'package:web_socket_client/web_socket_client.dart';

import '../data/model/symbol_model.dart';

class FinnHubRepository {
  final FinnHubSymbolApiService _finnHubSymbolApiService;
  final FinnHubSocketService _finnHubSocketService;

  ///for symbols searching and
  ///for providing each instrument item bloc initial value
  Map<String, SymbolModel> inMemoryDB = {};

  ///if socket reconnect then we need to re-subscribe
  Set<String> subscriberSet = {};

  FinnHubRepository(
      {FinnHubSymbolApiService? finnHubSymbolApiService,
      FinnHubSocketService? finnHubSocketService})
      : _finnHubSymbolApiService =
            finnHubSymbolApiService ?? FinnHubSymbolApiService(),
        _finnHubSocketService = finnHubSocketService ?? FinnHubSocketService();

  Future<List<SymbolModel>> getSymbols(
      {required String path, required String exchange}) async {
    final symbols = await _finnHubSymbolApiService.getSymbols(
        path: path, exchange: exchange);

    return symbols;
  }

  Future<void> saveSymbolToInMemoryDB(List<SymbolModel> symbols) async {
    ///isolate to convert list to map for large data
    inMemoryDB = await compute(_saveSymbolToInMemoryDB, symbols);
  }

  void connectToSocket() {
    _finnHubSocketService.init();
  }

  void closeSocket() {
    _finnHubSocketService.close();
  }

  Stream<String> listenToMessage() async* {
    await for (final message in _finnHubSocketService.listenToMessage()) {
      for (var d in (message as List<dynamic>)) {
        ///for faster lookup used inMemoryDB and
        ///yield only if symbols data updated
        final SymbolModel symbol = inMemoryDB[d["s"]]!;
        double formattedPrice = double.parse(d["p"].toStringAsFixed(2));
        if (symbol.price == null) {
          final updatedSymbol =
              symbol.copyWith(price: formattedPrice, isPriceIncreasing: true);
          inMemoryDB[d["s"]] = updatedSymbol;
          yield updatedSymbol.symbol!;
        } else if (symbol.price != null && symbol.price != formattedPrice) {
          final newPrice = formattedPrice;
          final oldPrice = symbol.price ?? 0.0;
          final updatedSymbol = symbol.copyWith(
              price: formattedPrice,
              isPriceIncreasing: newPrice > oldPrice ? true : false);
          inMemoryDB[d["s"]] = updatedSymbol;
          yield updatedSymbol.symbol!;
        } else {
          if (symbol.isPriceIncreasing != null) {
            final updatedSymbol = symbol.copyWith(
              isPriceIncreasing: null,
            );
            inMemoryDB[d["s"]] = updatedSymbol;
            yield updatedSymbol.symbol!;
          }
        }
      }
    }
  }

  /// in free tier finnhub api only accept 50 subscriptions at a time
  void socketSubscribeUnsubscribeSymbols(
      Set<String> symbols, bool isNewSubscribersList) {
    if (setEquals(subscriberSet, symbols)) {
      return;
    }
    if (isNewSubscribersList) {
      for (String symbol in subscriberSet) {
        _finnHubSocketService.socket!
            .send(jsonEncode({"type": "unsubscribe", "symbol": symbol}));
      }
      subscriberSet.clear();
    }
    for (String symbol in symbols) {
      _finnHubSocketService.socket!
          .send(jsonEncode({"type": "subscribe", "symbol": symbol}));
    }
    if (isNewSubscribersList) {
      subscriberSet.addAll(symbols);
    }
  }

  void listenToSocketConnectionState() {
    _finnHubSocketService.socket!.connection.listen(
      (ConnectionState state) {
        log(state.toString());
        if (state is Reconnected) {
          ///Re-subscribe previous symbols if any
          if (subscriberSet.isNotEmpty) {
            socketSubscribeUnsubscribeSymbols(subscriberSet, false);
          }
        }
      },
    );
  }
}

//Isolate function
Map<String, SymbolModel> _saveSymbolToInMemoryDB(List<SymbolModel> symbols) {
  return {for (SymbolModel e in symbols) e.symbol!: e};
}
