import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'dio_logging_interceptor.dart';
import 'json_body_interceptor.dart';

/// Shared [Dio] instance for remote calls.
class DioClient {
  DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(JsonBodyInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(DioLoggingInterceptor());
    }

    return dio;
  }
}
