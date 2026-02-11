import 'package:dio/dio.dart';
import 'package:log_reporter/app_log_reporter.dart';

class ApiMetricsInterceptor extends Interceptor {
  final ScreenTrackingObserver screenObserver;
  final List<int> statusCodeIgnore;

  ApiMetricsInterceptor(this.screenObserver, {required this.statusCodeIgnore});

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

    // 🔑 Deduplication check
    final shouldLog = ApiErrorDeduplicator.shouldLog(
      statusCode: statusCode,
      path: options.path,
      screenName: screenObserver.currentScreen?.screenName,
      statusCodeIgnore: statusCodeIgnore,
    );

    // Create structured API log
    final apiLog = ApiLog(
      method: options.method,
      url: options.path,
      durationMs: duration,
      isError: error != null,
      dioException: error,
    );

    // // Attach API log to current screen
    final errorLog = ErrorLog(
      stackTrace: error?.stackTrace,
      time: null,
      type: ErrorLogType.api,
      apiLog: apiLog,
      screenLog: null,
    );

    // Also capture errors into structured error logs
    if (error != null) {
      if (!shouldLog) {
        return; // 🚫 Skip duplicate unauthorized logs
      }

      // Log with Talker
      talker.error(
        '[API ERROR-${options.method}]-[${screenObserver.currentScreen?.screenName}]- ${options.path} (${duration}ms) at ${start.toString()}',
        errorLog.generateErrorMsg(),
        error.stackTrace,
      );

      // Send immediate report for API errors
      AppLogReporter.immediateReporter?.sendImmediateErrorReport(
        errorType: 'API Error',
        message: errorLog.generateErrorMsg(),
        exception: error,
        stackTrace: error.stackTrace,
        dioException: error,
        screenName: screenObserver.currentScreen?.screenName,
      );
    } else {
      if (isSlow) {
        talker.warning(
          '[Slow API-${options.method}]-[${screenObserver.currentScreen?.screenName}]- ${options.path} - ${duration}ms at ${start.toString()}',
          errorLog.generateErrorMsg(),
        );
      }
    }
  }
}

class ApiErrorDeduplicator {
  static final Set<String> _loggedErrors = {};

  static bool shouldLog({
    required int? statusCode,
    required String path,
    required String? screenName,
    required List<int> statusCodeIgnore,
  }) {
    // Only deduplicate authorization errors
    if (statusCodeIgnore.contains(statusCode)) {
      return false;
    } else {
      final fingerprint = '$statusCode|$path|$screenName';
      if (_loggedErrors.contains(fingerprint)) {
        return false; // already logged
      }

      _loggedErrors.add(fingerprint);
      return true;
    }
  }

  static void clear() {
    _loggedErrors.clear(); // call daily or after email sent
  }
}
