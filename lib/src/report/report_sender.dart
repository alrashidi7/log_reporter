import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:log_reporter/app_log_reporter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ReportSender {
  static Future<void> sendEmail({
    required LogReporterConfig config,
    required String report,
    BuildContext? context,
  }) async {
    final smtpServer = gmail(config.smtpEmail, config.appPassword);
    final message = Message()
      ..from = Address(config.smtpEmail, '-${config.appName}- App Logger Alert')
      ..recipients.add(config.toEmail)
      ..subject =
          'Daily App Report :: ${config.appName}-${config.isProduction ? "PROD" : "STAGING"} :: ${DateTime.now()}'
      ..text = report;
    try {
      await send(message, smtpServer);
      AppLogReporter.talker.cleanHistory();
      if (context.runtimeType != Null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              content: Text('Send Successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    } catch (e) {
      Clipboard.setData(ClipboardData(text: e.toString()));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text('error copied , send email Erorr : ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }
}
