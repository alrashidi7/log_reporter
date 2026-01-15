import 'package:dio/dio.dart';
import 'package:log_reporter/app_log_reporter.dart';
import 'package:log_reporter/src/model/screen_log.dart';
import 'package:talker_flutter/talker_flutter.dart';

class ApiMetricsInterceptor extends Interceptor {
  final ScreenTrackingObserver screenObserver;

  ApiMetricsInterceptor(this.screenObserver);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Track start time for duration calculation
    options.extra['startTime'] = DateTime.now();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logApi(response.requestOptions, response.statusCode);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logApi(err.requestOptions, err.response?.statusCode, error: err);
    super.onError(err, handler);
  }

  void _logApi(RequestOptions options, int? statusCode, {DioException? error}) {
    final start = options.extra['startTime'] as DateTime?;
    if (start == null) return;

    final duration = DateTime.now().difference(start).inMilliseconds;
    final isSlow = duration > AppLogReporter.config.slowApiThresholdMs;
    final talker = AppLogReporter.talker;

    // Create structured API log
    final apiLog = ApiLog(
      method: options.method,
      url: options.path,
      durationMs: duration,
      isError: error != null,
    );

    // Attach API log to current screen
    screenObserver.addApiLog(apiLog);

    // Also capture errors into structured error logs
    if (error != null) {
      final errorLog = ErrorLog(
        message: error.message ?? '',
        stackTrace: error.stackTrace,
        type: 'api_error',
      );
      screenObserver.addError(errorLog);

      // Log with Talker
      talker.error(
        '[MyAppLog][API ERROR] ${options.method} ${options.path} (${duration}ms)',
        error,
        error.stackTrace,
      );
    } else {
      // Normal API log
      talker.log(
        '[MyAppLog][API] ${options.method} ${options.path} (${duration}ms)',
        logLevel: isSlow ? LogLevel.warning : LogLevel.info,
      );

      if (isSlow) {
        talker.warning(
          '[MyAppLog][Slow API] ${options.method} ${options.path} - ${duration}ms',
        );
      }
    }
  }
}
