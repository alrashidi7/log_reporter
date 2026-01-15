import 'package:talker_flutter/talker_flutter.dart';

import 'smart_daily_report_builder.dart';
import 'report_sender.dart';
import '../core/reporter.dart';

class SmartEmailReporter {
  /// Threshold for slow APIs to trigger email
  final int slowApiThresholdCount;

  /// If true, will send email even if only slow APIs exist
  final bool notifyOnSlowApiOnly;

  SmartEmailReporter({
    this.slowApiThresholdCount = 1,
    this.notifyOnSlowApiOnly = false,
  });

  /// Call at end of day or on-demand
  Future<void> sendDailyReportIfNeeded({
    required String smtpEmail,
    required String appPassword,
    required String toEmail,

    required String appName,
    required bool isProduction,
  }) async {
    final logs = AppLogReporter.talker.history;
    // Filter today's logs
    final today = logs.where((log) => _isToday(log.time)).toList();
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
    if (!shouldSend) return;
    // Build professional report
    final report = SmartDailyReportBuilder.build();

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

  bool _isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }
}
