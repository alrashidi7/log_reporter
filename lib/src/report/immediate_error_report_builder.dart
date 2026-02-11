import 'package:dio/dio.dart';
import 'package:log_reporter/app_log_reporter.dart';

/// Builds a focused report for a single critical error (API or crash)
/// Includes device, network, app version, and full error trace.
class ImmediateErrorReportBuilder {
  final LoggerAppContext loggerAppContext;

  ImmediateErrorReportBuilder({required this.loggerAppContext});

  String _pretty(String key) => key.replaceAll('_', ' ').toUpperCase();

  Future<String> build({
    required String errorType,
    required String message,
    Object? exception,
    StackTrace? stackTrace,
    DioException? dioException,
    String? screenName,
  }) async {
    final context = loggerAppContext.data;
    final networkInfo = await loggerAppContext.getNetworkInfo();

    final buffer = StringBuffer();

    buffer.writeln('🚨 Immediate Error Alert - $errorType\n');
    buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Screen: ${screenName ?? "Unknown"}\n');

    buffer.writeln('------------------------------');
    buffer.writeln('📱 App Information');
    buffer.writeln('• App: ${context['app_name']}');
    buffer.writeln(
      '• Version: ${context['version']} (${context['build_number']})',
    );
    buffer.writeln('• Environment: ${context['environment']}');
    buffer.writeln('• Locale: ${context['locale']}');
    buffer.writeln('• Timezone: ${context['timezone']}');

    buffer.writeln('\n📲 Device Information');
    final device = context['device'] as Map;
    device.forEach((k, v) {
      buffer.writeln('• ${_pretty(k)}: $v');
    });

    buffer.writeln('\n🌐 Network Information');
    networkInfo.forEach((k, v) {
      buffer.writeln('• ${_pretty(k)}: $v');
    });

    buffer.writeln('\n------------------------------');
    buffer.writeln('Error Details');
    buffer.writeln('------------------------------');
    buffer.writeln('\nMessage: $message');

    if (dioException != null) {
      buffer.writeln('\nAPI Error Details:');
      buffer.writeln('• Method: ${dioException.requestOptions.method}');
      buffer.writeln('• URL: ${dioException.requestOptions.uri}');
      buffer.writeln('• Status: ${dioException.response?.statusCode}');
      if (dioException.requestOptions.data != null) {
        buffer.writeln('• Request Body: ${dioException.requestOptions.data}');
      }
      if (dioException.response?.data != null) {
        buffer.writeln('• Response: ${dioException.response?.data}');
      }
    }

    if (exception != null) {
      buffer.writeln('\nException: $exception');
    }

    if (stackTrace != null && stackTrace.toString().isNotEmpty) {
      buffer.writeln('\nStack Trace:');
      buffer.writeln(stackTrace.toString());
    }

    return buffer.toString();
  }
}
