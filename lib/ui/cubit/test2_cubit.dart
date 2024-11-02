import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:trading_instruments/ui/cubit/test_cubit.dart';

part 'test2_state.dart';

class Test2Cubit extends Cubit<Test2State> {
  Test2Cubit() : super(Test2State());

  void updateState() {
    Timer.periodic(Duration(seconds: 1), (_) {
      final key = mySymbols.keys.elementAt(Random().nextInt(15));
      mySymbols[key] = mySymbols[key]!.copyWith(
        price: Random().nextInt(1000).toDouble(),
      );
      emit(Test2State(
        symbol: key,
      ));
    });
  }
}
