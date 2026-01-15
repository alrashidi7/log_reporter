import 'package:dio/dio.dart';

class ScreenLog {
  final String screenName;
  final DateTime openedAt;
  DateTime? closedAt;
  final List<ApiLog> apiLogs;
  final List<ErrorLog> errors;

  ScreenLog({
    required this.screenName,
    required this.openedAt,
    this.closedAt,
    List<ApiLog>? apiLogs,
    List<ErrorLog>? errors,
  }) : apiLogs = apiLogs ?? [],
       errors = errors ?? [];

  int? get durationMs => closedAt?.difference(openedAt).inMilliseconds;
}

class ApiLog {
  final String method;
  final String url;
  final int durationMs;
  final bool isError;

  ApiLog({
    required this.method,
    required this.url,
    required this.durationMs,
    this.isError = false,
  });
}

class ErrorLog {
  String message;
  final StackTrace? stackTrace;
  DateTime? time;
  final String? type;
  final DioException? dioException;

  ErrorLog({
    required this.message,
    this.stackTrace,
    this.time,
    this.type,
    this.dioException,
  }) {
    time = time ?? DateTime.now();

    if (dioException.runtimeType != Null) {
      var logData = {
        "status_code": dioException?.response?.statusCode,
        "request_url": dioException?.response?.realUri.toString(),
        "request_body": dioException?.requestOptions.data,
        "request_response": dioException?.response?.data,
      };
      message = "$message${logData.entries.join("\n")}";
    }
  }
}
