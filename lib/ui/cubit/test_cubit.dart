import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:trading_instruments/data/model/symbol_model.dart';
import 'package:trading_instruments/data/service/finn_hub_symbol_api_service.dart';

part 'test_state.dart';

Map<String, SymbolModel> mySymbols = {};

class TestCubit extends Cubit<TestState> {
  TestCubit() : super(TestLoading());

  void loadData() async {
    final List<SymbolModel> symbols = await FinnHubSymbolApiService()
        .getSymbols(path: "/crypto/symbol", exchange: "binance");
    mySymbols = Map.fromEntries(
      symbols.map((e) => MapEntry(e.symbol!, e)),
    );
    symbols.clear();
    emit(TestData());
  }
}
