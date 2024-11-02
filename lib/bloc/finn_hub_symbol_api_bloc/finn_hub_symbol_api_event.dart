part of 'finn_hub_symbol_api_bloc.dart';

sealed class FinnHubSymbolApiEvent extends Equatable {
  const FinnHubSymbolApiEvent();
}

class FinnHubSymbolApiFetchEvent extends FinnHubSymbolApiEvent {
  const FinnHubSymbolApiFetchEvent();

  @override
  List<Object?> get props => [];
}
