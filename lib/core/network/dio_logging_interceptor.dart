import 'dart:convert';

import 'package:dio/dio.dart';

const _requestStartKey = '_dio_log_request_start_ms';

/// Prints every Dio request / response / error using `print`.
class DioLoggingInterceptor extends Interceptor {
  static const _encoder = JsonEncoder.withIndent('  ');

  static String _formatBody(Object? data) {
    if (data == null) return '(no body)';
    if (data is Map || data is List) {
      try {
        return _encoder.convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    if (data is FormData) {
      return '(FormData: ${data.fields.length} fields, '
          '${data.files.length} files)';
    }
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map || decoded is List) {
            return _encoder.convert(decoded);
          }
        } catch (_) {
          // keep raw string
        }
      }
      return data;
    }
    return data.toString();
  }

  // ignore: avoid_print
  void _log(String msg) => print(msg);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_requestStartKey] = DateTime.now().millisecondsSinceEpoch;
    final buf = StringBuffer('→ ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      buf
        ..writeln()
        ..write('  query: ${options.queryParameters}');
    }
    if (options.data != null && options.method.toUpperCase() != 'GET') {
      buf
        ..writeln()
        ..write(_formatBody(options.data));
    }
    _log(buf.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final opts = response.requestOptions;
    final start = opts.extra[_requestStartKey] as int?;
    final elapsed = start == null
        ? ''
        : ' (${DateTime.now().millisecondsSinceEpoch - start}ms)';
    final status = response.statusCode ?? 0;
    _log('← $status ${opts.method} ${response.realUri}$elapsed');
    _log(_formatBody(response.data));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final opts = err.requestOptions;
    final start = opts.extra[_requestStartKey] as int?;
    final elapsed = start == null
        ? ''
        : ' (${DateTime.now().millisecondsSinceEpoch - start}ms)';
    final status = err.response?.statusCode;
    _log(
      '✗ ${opts.method} ${opts.uri}$elapsed'
      '${status != null ? ' → $status' : ''} — ${err.message ?? err.type}',
    );
    if (err.response?.data != null) {
      _log(_formatBody(err.response?.data));
    }
    handler.next(err);
  }
}
