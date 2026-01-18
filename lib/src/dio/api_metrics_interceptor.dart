import 'package:dio/dio.dart';
import 'package:log_reporter/app_log_reporter.dart';

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
      dioException: error,
    );

    // Attach API log to current screen
    screenObserver.addApiLog(apiLog);
    final errorLog = ErrorLog(
      stackTrace: error?.stackTrace,
      time: null,
      type: ErrorLogType.api,
      apiLog: apiLog,
      screenLog: null,
    );

    // Also capture errors into structured error logs
    if (error != null) {
      //  = ErrorLog(
      //   message: error.message ?? '',
      //   dioException: error,
      //   stackTrace: error.stackTrace,
      //   type: 'api_error',
      // );

      // Log with Talker
      talker.error(
        '[API ERROR]-[${screenObserver.currentScreen?.screenName}]- ${options.method} ${options.path} (${duration}ms)',
        errorLog.generateErrorMsg(),
        error.stackTrace,
      );
    } else {
      // Normal API log
      // talker.log(
      //   '[API]-[${screenObserver.currentScreen?.screenName}]- ${options.method} ${options.path} (${duration}ms)',
      //   logLevel: isSlow ? LogLevel.warning : LogLevel.info,
      // );

      if (isSlow) {
        talker.warning(
          '[Slow API]-[${screenObserver.currentScreen?.screenName}]- ${options.method} ${options.path} - ${duration}ms',
          errorLog.generateErrorMsg(),
        );
      }
    }
  }
}
