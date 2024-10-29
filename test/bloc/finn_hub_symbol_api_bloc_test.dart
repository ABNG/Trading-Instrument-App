import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_instruments/bloc/finn_hub_symbol_api_bloc/finn_hub_symbol_api_bloc.dart';
import 'package:trading_instruments/repository/finn_hub_repository.dart';

class MockFinnHubRepository extends Mock implements FinnHubRepository {}

void main() async {
  await dotenv.load();
  late MockFinnHubRepository finnHubRepository;
  late FinnHubSymbolApiBloc finnHubSymbolApiBloc;

  setUp(() {
    finnHubRepository = MockFinnHubRepository();
    finnHubSymbolApiBloc =
        FinnHubSymbolApiBloc(finnHubRepository: finnHubRepository);
  });

  tearDown(() => finnHubSymbolApiBloc.close());

  test('initial state is correct', () {
    expect(finnHubSymbolApiBloc.state, FinnHubSymbolApiLoading());
  });

  group('getSymbols', () {
    blocTest<FinnHubSymbolApiBloc, FinnHubSymbolApiState>(
      '''emits error state when getSymbols called''',
      setUp: () {
        when(() => finnHubRepository.getSymbols(
            path: "forex/symbol", exchange: "oanda")).thenThrow(Exception());
      },
      build: () => finnHubSymbolApiBloc,
      act: (bloc) => bloc.add(const FinnHubSymbolApiFetchEvent()),
      expect: () => <FinnHubSymbolApiState>[
        FinnHubSymbolApiLoading(),
        FinnHubSymbolApiFailure(message: "something went wrong"),
      ],
    );
  });
}
