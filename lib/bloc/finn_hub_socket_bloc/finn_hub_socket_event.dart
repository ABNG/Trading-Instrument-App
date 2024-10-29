part of 'finn_hub_socket_bloc.dart';

sealed class FinnHubSocketEvent extends Equatable {
  const FinnHubSocketEvent();
}

class FinnHubSocketInitializedEvent extends FinnHubSocketEvent {
  const FinnHubSocketInitializedEvent();
  @override
  List<Object> get props => [];
}

class FinnHubSocketSubscribeUnSubscribeEvent extends FinnHubSocketEvent {
  final Set<String> symbols;
  final bool isNewSubscribersList;

  const FinnHubSocketSubscribeUnSubscribeEvent(
      {required this.symbols, this.isNewSubscribersList = true});

  @override
  String toString() {
    return 'FinnHubSocketSubscribeUnSubscribeEvent{symbols: $symbols, isNewSubscribersList: $isNewSubscribersList}';
  }

  @override
  List<Object> get props => [symbols, isNewSubscribersList];
}
