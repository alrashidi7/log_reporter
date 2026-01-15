import '../core/reporter.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DailyReportBuilder {
  static String build() {
    final logs = AppLogReporter.talker.history;

    final today = logs.where(
      (e) => e.time.day == DateTime.now().day,
    );

    final errors =
        today.where((e) => e.logLevel == LogLevel.error);

    final warnings =
        today.where((e) => e.logLevel == LogLevel.warning);

    return '''
Daily App Report

Total Logs: ${today.length}
Errors: ${errors.length}
Warnings: ${warnings.length}

Errors:
${errors.map((e) => '- ${e.message}').join('\n')}
''';
  }
}
