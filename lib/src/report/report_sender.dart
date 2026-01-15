import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ReportSender {
  static Future<void> sendEmail({
    required String smtpEmail,
    required String appPassword,
    required String toEmail,
    required String report,
    required String appName,
    required bool isProduction,
  }) async {
    final smtpServer = gmail(smtpEmail, appPassword);
    final message = Message()
      ..from = Address(smtpEmail, '-$appName- App Logger Alert')
      ..recipients.add(toEmail)
      ..subject =
          'Daily App Report :: $appName-${isProduction ? "PROD" : "STAGING"} :: ${DateTime.now()}'
      ..text = report;
    try {
      await send(message, smtpServer);
    } catch (e) {}
  }
}
