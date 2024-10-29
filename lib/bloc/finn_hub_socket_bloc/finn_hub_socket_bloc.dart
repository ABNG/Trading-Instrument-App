import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_instruments/repository/finn_hub_repository.dart';

part 'finn_hub_socket_event.dart';
part 'finn_hub_socket_state.dart';

///this bloc initialize, close and listen to socket connection and subscribe/unsubscribe symbols
class FinnHubSocketBloc extends Bloc<FinnHubSocketEvent, FinnHubSocketState> {
  final FinnHubRepository _finnHubRepository;

  FinnHubSocketBloc({required FinnHubRepository finnHubRepository})
      : _finnHubRepository = finnHubRepository,
        super(FinnHubSocketInitial()) {
    on<FinnHubSocketInitializedEvent>(
      (event, emit) async {
        emit(FinnHubSocketInitial());
        try {
          //init socket
          _finnHubRepository.connectToSocket();

          //listen to socket reconnect and subscribe symbols again
          _finnHubRepository.listenToSocketConnectionState();
        } on SocketException catch (e) {
          emit(FinnHubSocketFailure(message: e.message));
        } catch (e) {
          emit(
            FinnHubSocketFailure(
              message: e.toString(),
            ),
          );
        }
      },
    );

    on<FinnHubSocketSubscribeUnSubscribeEvent>((event, emit) {
      _finnHubRepository.socketSubscribeUnsubscribeSymbols(
          event.symbols, event.isNewSubscribersList);
    });
  }

  @override
  Future<void> close() {
    _finnHubRepository.closeSocket();
    return super.close();
  }
}
