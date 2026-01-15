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
  final String message;
  final StackTrace? stackTrace;
  final DateTime time;
  final String? type;

  ErrorLog({required this.message, this.stackTrace, DateTime? time, this.type})
    : time = time ?? DateTime.now();
}
