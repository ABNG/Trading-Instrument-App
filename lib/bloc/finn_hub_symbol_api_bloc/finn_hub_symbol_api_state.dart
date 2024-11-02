part of 'finn_hub_symbol_api_bloc.dart';

sealed class FinnHubSymbolApiState extends Equatable {
  const FinnHubSymbolApiState();
}

final class FinnHubSymbolApiLoading extends FinnHubSymbolApiState {
  @override
  List<Object> get props => [];
}

final class FinnHubSymbolApiSuccess extends FinnHubSymbolApiState {
  final List<SymbolModel> symbols;

  const FinnHubSymbolApiSuccess({required this.symbols});

  @override
  List<Object> get props => [symbols];
}

final class FinnHubSymbolApiFailure extends FinnHubSymbolApiState {
  final String message;

  const FinnHubSymbolApiFailure({required this.message});
  @override
  List<Object> get props => [message];
}
