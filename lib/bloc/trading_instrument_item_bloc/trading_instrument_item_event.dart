part of 'trading_instrument_item_bloc.dart';

sealed class TradingInstrumentItemEvent extends Equatable {
  const TradingInstrumentItemEvent();
}

class TradingInstrumentItemListenEvent extends TradingInstrumentItemEvent {
  final String symbol;
  const TradingInstrumentItemListenEvent(this.symbol);
  @override
  List<Object> get props => [symbol];
}
