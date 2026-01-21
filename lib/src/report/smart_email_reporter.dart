import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:log_reporter/app_log_reporter.dart';

class EmailContent {
  final String subject;
  final String body;

  EmailContent({required this.subject, required this.body});
}

class SmartEmailReporter {
  final LogReporterConfig config;

  SmartEmailReporter({required this.config});
  Future<void> sendReport() async {
    final emailContent = await prepareReport();

    if (emailContent.runtimeType != Null) {
      if (kDebugMode) {
        log('---------------------------');
        log('--- Daily Email Preview ---');
        log('To: ${config.toEmail}');
        log('Subject: ${emailContent?.subject}');
        log('Body:\n${emailContent?.body}');
        log('---------------------------');
        log('---------------------------');
      }
      // Send email
      await ReportSender.sendEmail(
        report: emailContent?.body ?? "",
        config: config,
      );
    } else {}
  }

  /// Prepare the email report and return EmailContent
  Future<EmailContent?> prepareReport() async {
    final reportBody = SmartDailyReportBuilder().build();

    return reportBody.runtimeType == Null
        ? null
        : EmailContent(
            subject: '[${config.appName}] Daily Log Report',
            body: reportBody!,
          );
  }
}
