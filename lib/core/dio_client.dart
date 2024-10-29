import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Dio get appDioClient => Dio(
      BaseOptions(baseUrl: 'https://finnhub.io/api/v1/', queryParameters: {
        "token": dotenv.env['TOKEN'],
      }),
    );
