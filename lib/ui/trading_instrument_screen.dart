import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_instruments/bloc/finn_hub_symbol_api_bloc/finn_hub_symbol_api_bloc.dart';
import 'package:trading_instruments/repository/finn_hub_repository.dart';
import 'package:trading_instruments/ui/search_screen.dart';

import '../bloc/finn_hub_socket_bloc/finn_hub_socket_bloc.dart';
import '../bloc/trading_instrument_item_bloc/trading_instrument_item_bloc.dart';

class TradingInstrumentScreen extends StatelessWidget {
  const TradingInstrumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => FinnHubRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FinnHubSocketBloc(
                finnHubRepository:
                    RepositoryProvider.of<FinnHubRepository>(context))
              ..add(
                FinnHubSocketInitializedEvent(),
              ),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => FinnHubSymbolApiBloc(
                finnHubRepository:
                    RepositoryProvider.of<FinnHubRepository>(context))
              ..add(
                FinnHubSymbolApiFetchEvent(),
              ),
          ),
          BlocProvider(
            create: (context) => TradingInstrumentItemBloc(
              finnHubRepository:
                  RepositoryProvider.of<FinnHubRepository>(context),
            )..add(
                TradingInstrumentItemListenEvent(),
              ),
          ),
        ],
        child: TradingInstrumentView(),
      ),
    );
  }
}

class TradingInstrumentView extends StatefulWidget {
  const TradingInstrumentView({super.key});

  @override
  State<TradingInstrumentView> createState() => _TradingInstrumentViewState();
}

class _TradingInstrumentViewState extends State<TradingInstrumentView> {
  ///in free tier only 50 symbols can subscribed be at once
  ///once user stop scrolling, subscribe currently visible symbols/items to socket
  ///and unsubscribe previous symbols
  ///
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollStopTimer;
  bool isFirstTimeLoad = true;
  double _lastScrollPosition = 0.0;

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (_scrollStopTimer != null) {
        _scrollStopTimer!.cancel();
      }
    }
    if (notification is ScrollEndNotification) {
      _onScroll(notification);
    }
    return true;
  }

  void _onScroll([ScrollEndNotification? notification]) {
    // Cancel any existing timer when the user is scrolling

    _scrollStopTimer = Timer(Duration(milliseconds: 200), () {
      if (notification == null) {
        _onScrollStopped();
        return;
      }
      final double currentScrollPosition = notification.metrics.pixels;
      final double scrollDifference =
          (max(0, currentScrollPosition) - _lastScrollPosition).abs();
      if (scrollDifference >= 275) {
        _onScrollStopped();
        _lastScrollPosition = currentScrollPosition;
      }
    });
  }

  void _onScrollStopped() {
    print("Scroll End");
    int itemCount = context.read<FinnHubRepository>().inMemoryDB.length;
    double scrollOffset = _scrollController.position.pixels;
    double viewportHeight = _scrollController.position.viewportDimension;
    double scrollRange = _scrollController.position.maxScrollExtent -
        _scrollController.position.minScrollExtent;
    int firstVisibleItemIndex = max(
        0,
        (scrollOffset / (scrollRange + viewportHeight) * itemCount).floor() -
            15);

    int lastVisibleItemIndex = min(
        itemCount,
        ((scrollOffset + viewportHeight) /
                    (scrollRange + viewportHeight) *
                    itemCount)
                .floor() +
            15);

    Set<String> subSetSymbols = context
        .read<FinnHubRepository>()
        .inMemoryDB
        .values
        .toList()
        .sublist(firstVisibleItemIndex, lastVisibleItemIndex)
        .map((e) => e.symbol!)
        .toSet();
    context
        .read<FinnHubSocketBloc>()
        .add(FinnHubSocketSubscribeUnSubscribeEvent(symbols: subSetSymbols));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }

////////symbols subscribe/unSubscribe logic ends here/////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trading Instruments"),
        actions: [
          IconButton(
              onPressed: () async {
                await showSearch(
                  context: context,
                  delegate: SearchScreen(
                    inMemoryDB: context.read<FinnHubRepository>().inMemoryDB,
                  ),
                );
              },
              icon: Icon(Icons.search))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_scrollController.hasClients) {
            return;
          }
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: Duration(seconds: 2),
            curve: Curves.fastOutSlowIn,
          );
        },
        child: Icon(Icons.arrow_upward),
      ),
      body: BlocListener<FinnHubSocketBloc, FinnHubSocketState>(
        listener: (context, state) {
          if (state is FinnHubSocketFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(days: 365),
                content: Text(state.message),
                action: SnackBarAction(
                    label: "Retry",
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      context
                          .read<FinnHubSocketBloc>()
                          .add(FinnHubSocketInitializedEvent());
                    }),
              ),
            );
          }
        },
        child: BlocConsumer<FinnHubSymbolApiBloc, FinnHubSymbolApiState>(
          listener: (context, state) {
            ///subscribe to the initially visible symbols
            if (state is FinnHubSymbolApiSuccess && isFirstTimeLoad) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _onScroll();
                isFirstTimeLoad = false;
              });
            }
          },
          builder: (context, state) {
            return switch (state) {
              FinnHubSymbolApiLoading() => Center(
                  child: Transform.scale(
                      scale: 2.0, child: CircularProgressIndicator.adaptive()),
                ),
              FinnHubSymbolApiSuccess() =>
                NotificationListener<ScrollNotification>(
                  onNotification: handleScrollNotification,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.symbols.length,
                    prototypeItem: ListTile(
                      title: Text(
                        state.symbols.first,
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        child: Text("Loading..."),
                      ),
                    ),
                    itemBuilder: (context, index) => TradingInstrumentItem(
                      symbol: state.symbols[index],
                    ),
                    // separatorBuilder: (context, index) => Divider(),
                  ),
                ),
              FinnHubSymbolApiFailure() => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      ElevatedButton(
                          onPressed: () {
                            isFirstTimeLoad = true;
                            context
                                .read<FinnHubSymbolApiBloc>()
                                .add(FinnHubSymbolApiFetchEvent());
                          },
                          child: Text("Retry")),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

class TradingInstrumentItem extends StatelessWidget {
  final String symbol;

  const TradingInstrumentItem({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        symbol,
        style: TextStyle(fontSize: 12),
      ),
      trailing:
          BlocBuilder<TradingInstrumentItemBloc, TradingInstrumentItemState>(
        buildWhen: (prev, current) => symbol == current.symbol,
        builder: (context, state) {
          final symbolModel =
              context.read<FinnHubRepository>().inMemoryDB[symbol]!;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: (symbolModel.price ?? 0.0) == 0.0
                ? Text("Loading...")
                : Text(
                    symbolModel.price.toString(),
                    key: ValueKey<String>(symbolModel.price.toString()),
                    style: TextStyle(
                      color: symbolModel.isPriceIncreasing == null
                          ? null
                          : symbolModel.isPriceIncreasing!
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
