import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_instruments/repository/finn_hub_repository.dart';

part 'trading_instrument_item_event.dart';
part 'trading_instrument_item_state.dart';

///this bloc listen to the socket messages and
///update the state for specific instrument item only if data changes
class TradingInstrumentItemBloc
    extends Bloc<TradingInstrumentItemEvent, TradingInstrumentItemState> {
  final FinnHubRepository _finnHubRepository;
  TradingInstrumentItemBloc({required FinnHubRepository finnHubRepository})
      : _finnHubRepository = finnHubRepository,
        super(TradingInstrumentItemState()) {
    on<TradingInstrumentItemListenEvent>((event, emit) async {
      await emit.forEach(
        _finnHubRepository.listenToMessage(),
        onData: (String symbol) {
          return TradingInstrumentItemState(symbol: symbol);
        },
      );
    });
  }
}
