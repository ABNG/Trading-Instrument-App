part of 'trading_instrument_item_bloc.dart';

sealed class TradingInstrumentItemEvent extends Equatable {
  const TradingInstrumentItemEvent();
}

class TradingInstrumentItemListenEvent extends TradingInstrumentItemEvent {
  const TradingInstrumentItemListenEvent();
  @override
  List<Object> get props => [];
}
