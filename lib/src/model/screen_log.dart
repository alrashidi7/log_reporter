import 'package:dio/dio.dart';

enum ErrorLogType { ui, api, exeption }

class ScreenLog {
  final String screenName;
  final DateTime openedAt;
  DateTime? closedAt;
  final List<ErrorLog> errors;
  String? screenSummary;

  ScreenLog({
    required this.screenName,
    required this.openedAt,
    this.closedAt,
    List<ApiLog>? apiLogs,
    List<ErrorLog>? errors,
    this.screenSummary,
  }) : errors = errors ?? [];

  int? get durationMs => closedAt?.difference(openedAt).inMilliseconds;
}

class ApiLog {
  final String method;
  final String url;
  final int durationMs;
  final bool isError;
  final DioException? dioException;

  ApiLog({
    required this.method,
    required this.url,
    required this.durationMs,
    this.isError = false,
    this.dioException,
  });

  String generateApiLog() {
    String message = '-$method * $url Duration $durationMs Ms';

    if (dioException.runtimeType != Null) {
      var logData = {
        "status_code": dioException?.response?.statusCode,
        "request_url": dioException?.response?.realUri.toString(),
        "request_body": dioException?.requestOptions.data,
        "request_response": dioException?.response?.data,
      };

      String apiLogError = "";
      for (var element in logData.entries) {
        apiLogError =
            "$apiLogError \n---------\n ${element.key}:${element.value}";
      }
      message = "$message \n $apiLogError \n ---------\n";
    }
    return message;
  }
}

class ErrorLog {
  final StackTrace? stackTrace;
  DateTime? time;
  final ErrorLogType? type;
  final ScreenLog? screenLog;
  final ApiLog? apiLog;
  final String? exeptionMsg;

  ErrorLog({
    required this.stackTrace,
    required this.time,
    required this.type,
    required this.apiLog,
    required this.screenLog,
    this.exeptionMsg,
  }) {
    time = time ?? DateTime.now();
  }

  String generateErrorMsg() {
    switch (type) {
      case ErrorLogType.api:
        return apiLog?.generateApiLog() ?? exeptionMsg ?? '';

      case ErrorLogType.ui:
        return exeptionMsg ?? '';

      default:
        return exeptionMsg ?? "";
    }
  }
}
