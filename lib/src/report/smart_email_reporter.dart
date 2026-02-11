import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:log_reporter/app_log_reporter.dart';

class SmartEmailReporter {
  final LogReporterConfig config;
  final LoggerAppContext loggerAppContext;

  SmartEmailReporter({required this.config, required this.loggerAppContext});

  /// Sends an immediate error report (API error or app crash).
  /// Uses [ImmediateErrorReportBuilder] to include device, network, app version, and trace.
  Future<void> sendImmediateErrorReport({
    required String errorType,
    required String message,
    Object? exception,
    StackTrace? stackTrace,
    DioException? dioException,
    String? screenName,
  }) async {
    if (!config.enableEmailReport) return;

    final reportBody = await ImmediateErrorReportBuilder(
      loggerAppContext: loggerAppContext,
    ).build(
      errorType: errorType,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      dioException: dioException,
      screenName: screenName,
    );

    final subject =
        '[${config.appName}] ${config.isProduction ? "PROD" : "STAGING"} - $errorType - ${DateTime.now()}';

    if (kDebugMode) {
      // ignore: avoid_print
      print('--- Immediate Error Report ---');
      // ignore: avoid_print
      print('Subject: $subject');
      // ignore: avoid_print
      print('Body length: ${reportBody.length} chars');
    }

    await ReportSender.sendEmail(
      config: config,
      report: reportBody,
      subject: subject,
      clearHistoryOnSuccess: false,
    );
  }
}
