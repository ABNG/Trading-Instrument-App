import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_instruments/ui/cubit/test2_cubit.dart';
import 'package:trading_instruments/ui/cubit/test_cubit.dart';

class TestUi extends StatelessWidget {
  const TestUi({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TestCubit()..loadData(),
        ),
        BlocProvider(
          create: (context) => Test2Cubit()..updateState(),
        ),
      ],
      child: Scaffold(
        body: BlocBuilder<TestCubit, TestState>(
          builder: (context, state) {
            print("builder called");
            if (state is TestLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            print("builder called ${mySymbols.length}");
            final symbols = mySymbols.values.toList();
            return ListView.builder(
              itemCount: symbols.length,
              prototypeItem: ListTile(
                title: Text(symbols.first.symbol!),
                trailing: Text(symbols.first.price.toString() ?? "-"),
              ),
              itemBuilder: (context, index) =>
                  BlocBuilder<Test2Cubit, Test2State>(
                buildWhen: (previous, current) =>
                    current.symbol == symbols[index].symbol,
                builder: (context, state) {
                  return ListTile(
                    title: Text(symbols[index].symbol!),
                    trailing: Text(
                        mySymbols[symbols[index].symbol!]?.price.toString() ??
                            "-"),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
