import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../core/reporter.dart';

class ApiMetricsInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(err.requestOptions, err.response?.statusCode, error: err);
    handler.next(err);
  }

  void _log(RequestOptions options, int? statusCode, {DioException? error}) {
    final start = options.extra['startTime'] as DateTime?;
    if (start == null) return;

    final duration = DateTime.now().difference(start).inMilliseconds;

    final isSlow = duration > AppLogReporter.config.slowApiThresholdMs;

    final talker = AppLogReporter.talker;

    if (error != null) {
      talker.error(
        'API FAILED ${options.method} ${options.path}',
        error,
        error.stackTrace,
      );
    } else {
      talker.log(
        'API ${options.method} ${options.path} (${duration}ms)',
        logLevel: isSlow ? LogLevel.warning : LogLevel.info,
      );
    }

    if (isSlow) {
      talker.warning('Slow API: ${options.path} - ${duration}ms');
    }
  }
}
