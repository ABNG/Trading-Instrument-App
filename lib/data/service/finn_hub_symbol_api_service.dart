import 'dart:developer';

import 'package:dio/dio.dart';

import '../../core/dio_client.dart';
import '../model/symbol_model.dart';

class FinnHubSymbolApiService {
  final Dio _dioClient;

  FinnHubSymbolApiService({Dio? dioClient})
      : _dioClient = dioClient ?? appDioClient;

  Future<List<SymbolModel>> getSymbols(
      {required String path, required String exchange}) async {
    try {
      final Response response = await _dioClient.get(path, queryParameters: {
        "exchange": exchange,
      });

      final forexSymbols = response.data;

      if (forexSymbols is! List) {
        throw FormatException("Incorrect symbols format");
      }

      return forexSymbols
          .map((forexSymbol) => SymbolModel.fromJson(forexSymbol))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
