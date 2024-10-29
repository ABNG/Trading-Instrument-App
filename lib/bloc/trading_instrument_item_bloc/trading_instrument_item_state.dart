part of 'trading_instrument_item_bloc.dart';

sealed class TradingInstrumentItemState extends Equatable {
  const TradingInstrumentItemState();
}

class TradingInstrumentItemSuccess extends TradingInstrumentItemState {
  final SymbolModel symbolModel;
  const TradingInstrumentItemSuccess(this.symbolModel);

  @override
  List<Object?> get props => [symbolModel];
}
