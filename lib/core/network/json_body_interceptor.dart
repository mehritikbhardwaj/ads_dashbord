import 'dart:convert';

import 'package:dio/dio.dart';

/// Some upstreams (e.g. Postman mock) return JSON payloads with a non-JSON
/// `Content-Type` header, so Dio leaves [Response.data] as a raw [String].
/// This interceptor decodes such bodies into [Map] / [List] so typed data
/// sources can consume them without manual parsing.
class JsonBodyInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          response.data = jsonDecode(trimmed);
        } catch (_) {
          // Not valid JSON; leave the body untouched.
        }
      }
    }
    handler.next(response);
  }
}
