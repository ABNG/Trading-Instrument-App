import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_instruments/repository/finn_hub_repository.dart';

import '../../data/model/symbol_model.dart';

part 'finn_hub_symbol_api_event.dart';
part 'finn_hub_symbol_api_state.dart';

///this bloc is used to fetch symbols from finnhub api
class FinnHubSymbolApiBloc
    extends Bloc<FinnHubSymbolApiEvent, FinnHubSymbolApiState> {
  final FinnHubRepository _finnHubRepository;
  FinnHubSymbolApiBloc({
    required FinnHubRepository finnHubRepository,
  })  : _finnHubRepository = finnHubRepository,
        super(FinnHubSymbolApiLoading()) {
    on<FinnHubSymbolApiFetchEvent>((event, emit) async {
      emit(FinnHubSymbolApiLoading());
      try {
        final List<Future<List<SymbolModel>>> tradingInstruments = [
          _finnHubRepository.getSymbols(
              path: "/forex/symbol", exchange: "oanda"),
          _finnHubRepository.getSymbols(
              path: "/crypto/symbol", exchange: "binance"),
          // _finnHubRepository.getSymbols(path: "/stock/symbol", exchange: "US"),
        ];

        /// parallel api calls
        final List<List<SymbolModel>> results =
            await Future.wait(tradingInstruments);
        final List<SymbolModel> symbols = [];
        for (List<SymbolModel> result in results) {
          symbols.addAll(result);
        }
        await _finnHubRepository.saveSymbolToInMemoryDB(symbols);
        final symbolsList = symbols.map((e) => e.symbol!).toList();
        emit(FinnHubSymbolApiSuccess(symbols: symbolsList));
        print(symbolsList.length);
      } on DioException catch (e) {
        emit(FinnHubSymbolApiFailure(message: e.message.toString()));
      } on FormatException catch (e) {
        emit(FinnHubSymbolApiFailure(message: e.message.toString()));
      } catch (e) {
        emit(FinnHubSymbolApiFailure(message: "something went wrong"));
      }
    });
  }
}
