import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_instruments/data/model/symbol_model.dart';
import 'package:trading_instruments/data/service/finn_hub_symbol_api_service.dart';
import 'package:trading_instruments/repository/finn_hub_repository.dart';

class MockFinnHubSymbolApiService extends Mock
    implements FinnHubSymbolApiService {}

void main() async {
  await dotenv.load();
  late MockFinnHubSymbolApiService finnHubSymbolApiService;
  late FinnHubRepository finnHubRepository;

  setUp(() {
    finnHubSymbolApiService = MockFinnHubSymbolApiService();
    finnHubRepository =
        FinnHubRepository(finnHubSymbolApiService: finnHubSymbolApiService);
  });

  group('constructor', () {
    test(
      'does not require a FinnHubSymbolApiService and FinnHubSocketService',
      () => expect(FinnHubRepository(), isNotNull),
    );
  });

  group('getSymbols', () {
    test('return the List of SymbolModel', () async {
      //arrange
      when(() => finnHubSymbolApiService.getSymbols(
          path: "forex/symbol", exchange: "oanda")).thenAnswer(
        (_) async => [
          SymbolModel(
            symbol: "OANDA:NZD_SGD",
            description: "Oanda NZD/SGD",
            displaySymbol: "NZD/SGD",
          ),
        ],
      );
      //act
      final symbols = await finnHubRepository.getSymbols(
          path: "forex/symbol", exchange: "oanda");
      //assert
      verify(() => finnHubSymbolApiService.getSymbols(
          path: "forex/symbol", exchange: "oanda")).called(1);
      expect(symbols.first, isA<SymbolModel>());
    });

    test('throws an exception when getSymbols called', () async {
      // Arrange
      when(() => finnHubSymbolApiService.getSymbols(
          path: "forex/symbol", exchange: "oanda")).thenThrow(Exception());

      // Act & Assert
      expect(
        () async => await finnHubRepository.getSymbols(
            path: "forex/symbol", exchange: "oanda"),
        throwsException,
      );

      verify(() => finnHubSymbolApiService.getSymbols(
          path: "forex/symbol", exchange: "oanda")).called(1);
    });
  });
}
