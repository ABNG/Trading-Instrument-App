part of 'finn_hub_socket_bloc.dart';

sealed class FinnHubSocketState extends Equatable {
  const FinnHubSocketState();
}

final class FinnHubSocketInitial extends FinnHubSocketState {
  @override
  List<Object?> get props => [];
}

final class FinnHubSocketFailure extends FinnHubSocketState {
  final String message;

  const FinnHubSocketFailure({required this.message});
  @override
  List<Object> get props => [message];
}
