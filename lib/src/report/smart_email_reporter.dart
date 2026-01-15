import 'package:log_reporter/app_log_reporter.dart';
import 'package:talker_flutter/talker_flutter.dart';

class EmailContent {
  final String subject;
  final String body;

  EmailContent({required this.subject, required this.body});
}

class SmartEmailReporter {
  /// Threshold for slow APIs to trigger email
  final int slowApiThresholdCount;

  /// If true, will send email even if only slow APIs exist
  final bool notifyOnSlowApiOnly;

  SmartEmailReporter({
    this.slowApiThresholdCount = 1,
    this.notifyOnSlowApiOnly = false,
  });

  Future<void> sendReport({
    required String smtpEmail,
    required String appPassword,
    required String toEmail,
    required String appName,
    required bool isProduction,
    required String report,
  }) async {
    // Send email
    await ReportSender.sendEmail(
      smtpEmail: smtpEmail,
      appPassword: appPassword,
      toEmail: toEmail,
      report: report,
      appName: appName,
      isProduction: isProduction,
    );
  }

  /// Prepare the email report and return EmailContent
  Future<EmailContent> prepareReport({
    required String smtpEmail,
    required String appPassword,
    required String toEmail,
    required String appName,
    required bool isProduction,
  }) async {
    final logs = AppLogReporter.talker.history;

    // Filter today's logs
    final today = logs.where((log) => _isToday(log.time)).toList();

    // Errors and slow APIs
    final errors = today.where((e) => e.logLevel == LogLevel.error).toList();
    final slowApis = today
        .where(
          (e) =>
              e.logLevel == LogLevel.warning &&
              (e.message ?? '').contains('Slow API'),
        )
        .toList();

    // Decide if email is needed
    final shouldSend =
        errors.isNotEmpty ||
        (notifyOnSlowApiOnly && slowApis.length >= slowApiThresholdCount);

    if (!shouldSend) {
      return EmailContent(subject: '', body: '');
    }

    // Build professional report
    final reportBody = SmartDailyReportBuilder.build();

    return EmailContent(
      subject: '[${appName}] Daily Log Report',
      body: reportBody,
    );
  }

  bool _isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }
}
