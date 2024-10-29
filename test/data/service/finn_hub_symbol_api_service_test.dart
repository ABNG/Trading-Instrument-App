import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trading_instruments/data/model/symbol_model.dart';
import 'package:trading_instruments/data/service/finn_hub_symbol_api_service.dart';

class MockDioClient extends Mock implements Dio {}

void main() async {
  await dotenv.load();
  late MockDioClient dioClient;
  late FinnHubSymbolApiService finnHubSymbolApiService;

  setUp(() {
    dioClient = MockDioClient();
    finnHubSymbolApiService = FinnHubSymbolApiService(dioClient: dioClient);
  });

  group('constructor', () {
    test(
      'does not require a DioClient',
      () => expect(FinnHubSymbolApiService(), isNotNull),
    );
  });

  group('getSymbols', () {
    test('make correct http request to get Forex Symbols', () async {
      //arrange
      when(() => dioClient.get('forex/symbol',
          queryParameters: {'exchange': 'oanda'})).thenAnswer(
        (_) async => Response(
            requestOptions: RequestOptions(path: 'forex/symbol'),
            statusCode: 200,
            data: [
              {
                "description": "Oanda NZD/SGD",
                "displaySymbol": "NZD/SGD",
                "symbol": "OANDA:NZD_SGD"
              },
            ]),
      );
      //act
      final symbols = await finnHubSymbolApiService.getSymbols(
          path: "forex/symbol", exchange: "oanda");
      //assert
      verify(() => dioClient.get('forex/symbol',
          queryParameters: {'exchange': 'oanda'})).called(1);
      expect(symbols.first, isA<SymbolModel>());
    });

    test('throws an exception when the http request fails', () async {
      // Arrange
      when(() => dioClient.get('forex/symbol',
          queryParameters: {'exchange': 'oanda'})).thenThrow(DioException(
        requestOptions: RequestOptions(path: 'forex/symbol'),
        response: Response(
          requestOptions: RequestOptions(path: 'forex/symbol'),
          statusCode: 500,
          statusMessage: "Internal Server Error",
        ),
      ));

      // Act & Assert
      expect(
        () async => await finnHubSymbolApiService.getSymbols(
            path: "forex/symbol", exchange: "oanda"),
        throwsA(isA<DioException>()),
      );

      verify(() => dioClient.get('forex/symbol',
          queryParameters: {'exchange': 'oanda'})).called(1);
    });
  });
}
