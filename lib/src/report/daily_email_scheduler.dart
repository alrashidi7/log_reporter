import 'dart:async';

import 'smart_email_reporter.dart';

class DailyEmailScheduler {
  static Timer? _timer;

  static void start({
    required String smtpEmail,
    required String appPassword,
    required String toEmail,

    required String appName,
    required bool isProduction,
    int hour = 20,
    int minute = 0,
    int slowApiThresholdCount = 1,
    bool notifyOnSlowApiOnly = false,
  }) {
    _scheduleNextRun(
      smtpEmail: smtpEmail,
      appPassword: appPassword,
      toEmail: toEmail,
      hour: hour,
      minute: minute,
      slowApiThresholdCount: slowApiThresholdCount,
      notifyOnSlowApiOnly: notifyOnSlowApiOnly,
      appName: appName,
      isProduction: isProduction,
    );
  }

  static void _scheduleNextRun({
    required String smtpEmail,
    required String appPassword,
    required String toEmail,
    required String appName,
    required bool isProduction,
    required int hour,
    required int minute,
    required int slowApiThresholdCount,
    required bool notifyOnSlowApiOnly,
  }) {
    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, hour, minute);

    // if time already passed today, schedule for tomorrow
    if (nextRun.isBefore(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }

    final duration = nextRun.difference(now);

    _timer?.cancel();
    _timer = Timer(duration, () async {
      final reporter = SmartEmailReporter(
        slowApiThresholdCount: slowApiThresholdCount,
        notifyOnSlowApiOnly: notifyOnSlowApiOnly,
      );

      await reporter.sendDailyReportIfNeeded(
        smtpEmail: smtpEmail,
        appPassword: appPassword,
        toEmail: toEmail,
        appName: appName,
        isProduction: isProduction,
      );

      // Reschedule for next day
      _scheduleNextRun(
        smtpEmail: smtpEmail,
        appPassword: appPassword,
        toEmail: toEmail,
        appName: appName,
        isProduction: isProduction,
        hour: hour,
        minute: minute,
        slowApiThresholdCount: slowApiThresholdCount,
        notifyOnSlowApiOnly: notifyOnSlowApiOnly,
      );
    });
  }
}
