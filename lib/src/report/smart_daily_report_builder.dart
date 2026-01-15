import 'package:talker/talker.dart';
import '../core/reporter.dart';

class SmartDailyReportBuilder {
  static String build() {
    final logs = AppLogReporter.talker.history;

    final today = logs.where((e) => _isToday(e.time)).toList();

    final errors = today.where((e) => e.logLevel == LogLevel.error).toList();

    final warnings = today
        .where((e) => e.logLevel == LogLevel.warning)
        .toList();

    final slowApis = warnings
        .where((e) => (e.message ?? '').contains('Slow API'))
        .toList();

    final buffer = StringBuffer();

    buffer.writeln('Daily App Health Report\n');

    // Overall status
    if (errors.isEmpty && slowApis.isEmpty) {
      buffer.writeln('Overall Status: ✅ Healthy\n');
    } else {
      buffer.writeln('Overall Status: ⚠️ Attention Required\n');
    }

    // Summary
    buffer.writeln('Summary:');
    buffer.writeln('• Total logs: ${today.length}');
    buffer.writeln('• Errors detected: ${errors.length}');
    buffer.writeln('• Slow API requests: ${slowApis.length}\n');

    // Errors
    if (errors.isNotEmpty) {
      buffer.writeln('Error Details:');
      for (var i = 0; i < errors.length; i++) {
        buffer.writeln('${i + 1}. ${errors[i].message}');
      }
      buffer.writeln();
    }

    // Performance
    if (slowApis.isNotEmpty) {
      buffer.writeln('Performance Issues:');
      for (final log in slowApis) {
        buffer.writeln('• ${log.message}');
      }
      buffer.writeln();
    }

    // Conclusion
    buffer.writeln('Conclusion:');
    if (errors.isEmpty && slowApis.isEmpty) {
      buffer.writeln('No issues detected. No action required.');
    } else {
      buffer.writeln('Recommended to investigate the issues listed above.');
    }

    return buffer.toString();
  }

  static bool _isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }
}
