import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:log_reporter/app_log_reporter.dart';

import 'smart_email_reporter.dart';

class DailyEmailScheduler {
  Timer? _timer;
  final LogReporterConfig config;

  DailyEmailScheduler({required this.config});

  /// Start daily scheduling
  static void start({
    int hour = 20,
    int minute = 0,
    int slowApiThresholdCount = 1,
    bool notifyOnSlowApiOnly = false,
  }) {
    // scheduleNextRun(
    //   smtpEmail: smtpEmail,
    //   appPassword: appPassword,
    //   toEmail: toEmail,
    //   hour: hour,
    //   minute: minute,
    //   slowApiThresholdCount: slowApiThresholdCount,
    //   notifyOnSlowApiOnly: notifyOnSlowApiOnly,
    //   appName: appName,
    //   isProduction: isProduction,
    // );
  }

  /// Send email immediately
  Future<void> sendNow({
    int slowApiThresholdCount = 1,
    bool notifyOnSlowApiOnly = false,
    bool previewInConsole = true, // <-- new option
  }) async {
    final reporter = SmartEmailReporter(
      slowApiThresholdCount: slowApiThresholdCount,
      notifyOnSlowApiOnly: notifyOnSlowApiOnly,
    );

    final emailContent = await reporter.prepareReport(
      smtpEmail: config.smtpEmail,
      appPassword: config.appPassword,
      toEmail: config.toEmail,
      appName: config.appName,
      isProduction: config.isProduction,
    );

    if (previewInConsole && kDebugMode) {
      log('---------------------------');
      log('--- Daily Email Preview ---');
      log('To: ${config.toEmail}');
      log('Subject: ${emailContent.subject}');
      log('Body:\n${emailContent.body}');
      log('---------------------------');
      log('---------------------------');
    }

    // await reporter.sendReport(
    //   smtpEmail: smtpEmail,
    //   appPassword: appPassword,
    //   toEmail: toEmail,
    //   appName: appName,
    //   isProduction: isProduction,
    //   report: emailContent.body,
    // );
  }

  void scheduleNextRun({
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
      await sendNow(
        slowApiThresholdCount: slowApiThresholdCount,
        notifyOnSlowApiOnly: notifyOnSlowApiOnly,
        previewInConsole: false, // don't preview on scheduled run
      );

      // Reschedule for next day
      scheduleNextRun(
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
