import 'package:log_reporter/app_log_reporter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ReportSender {
  static Future<void> sendEmail({
    required LogReporterConfig config,
    required String report,
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
    } catch (e) {}
  }
}
