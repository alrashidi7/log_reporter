import 'package:collection/collection.dart';
import 'package:log_reporter/app_log_reporter.dart';

import 'package:talker/talker.dart';

class SmartDailyReportBuilder {
  final LoggerAppContext appContext;

  SmartDailyReportBuilder({required this.appContext});
  String _pretty(String key) => key.replaceAll('_', ' ').toUpperCase();
  String? build() {
    final logs = AppLogReporter.talker.history;

    final errors = logs.where((e) => e.logLevel == LogLevel.error).toList();

    final warnings = logs.where((e) => e.logLevel == LogLevel.warning).toList();

    List<TalkerData> warningListAfterFilter = [];
    for (var element in warnings) {
      final match = apiErrorRegex.firstMatch(element.message ?? '');
      if (match == null) {
        warningListAfterFilter.add(element);
      } else {
        final screen = match.group(2)!;
        final endpoint = match.group(3)!;
        final duration = int.parse(match.group(4)!);
        var itemFound = warningListAfterFilter.firstWhereOrNull(
          (element) => (element.message ?? "").contains(endpoint),
        );
        if (itemFound.runtimeType != Null) {
          warningListAfterFilter.add(element);
        } else {
          final matchitemFound = apiErrorRegex.firstMatch(
            itemFound?.message ?? '',
          );
          final durationItemFound = int.parse(matchitemFound?.group(4) ?? "0");
          if (duration > durationItemFound) {
            warningListAfterFilter.remove(itemFound);

            warningListAfterFilter.add(element);
          }
        }
      }
    }
    final slowApis = warningListAfterFilter
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
    final context = appContext.data;

    buffer.writeln("------------------------------");
    buffer.writeln('📱 App Information');
    buffer.writeln('• App: ${context['app_name']}');
    buffer.writeln(
      '• Version: ${context['version']} (${context['build_number']})',
    );
    buffer.writeln('• Environment: ${context['environment']}');

    buffer.writeln('\n📲 Device Information');
    final device = context['device'] as Map;
    device.forEach((k, v) {
      buffer.writeln('• ${_pretty(k)}: $v');
    });
    // Summary
    buffer.writeln("------------------------------");
    buffer.writeln('Summary:');
    buffer.writeln('• Total logs: ${logs.length}');
    buffer.writeln('• Errors detected: ${errors.length}');
    buffer.writeln('• Warnings detected: ${warningListAfterFilter.length}');
    buffer.writeln('• Slow API requests: ${slowApis.length}');
    buffer.writeln("------------------------------");
    // Errors
    if (errors.isNotEmpty) {
      buffer.writeln('Error Details:');
      for (var i = 0; i < errors.length; i++) {
        final message = errors[i].message ?? '';
        final match = apiErrorRegex.firstMatch(message);
        if (match == null) {
          buffer.writeln('• ${errors[i].message}');
        } else {}
      }
      if (groupApi(errors).isNotEmpty) {
        groupApi(errors).forEach(
          (element) => buffer.writeln(element.generateTheApiImpactSummary()),
        );
      }
      buffer.writeln("------------------------------");
    }

    // Warnings
    if (warningListAfterFilter.isNotEmpty) {
      buffer.writeln('Warning Details:');
      for (final log in warningListAfterFilter) {
        buffer.writeln('• ${log.message}');
      }
      buffer.writeln("------------------------------");
    }

    // // Performance
    // if (slowApis.isNotEmpty) {
    //   buffer.writeln('Performance Issues:');
    // for (final log in slowApis) {
    //   buffer.writeln('• ${log.message}');
    // }
    //   buffer.writeln();
    // }

    // Conclusion
    buffer.writeln('Conclusion:');
    if (errors.isEmpty && slowApis.isEmpty) {
      buffer.writeln('No issues detected. No action required.');
    } else {
      buffer.writeln('Recommended to investigate the issues listed above.');
    }
    if (errors.isEmpty && slowApis.isEmpty) {
      AppLogReporter.talker.cleanHistory();
      return null;
    } else {
      return buffer.toString();
    }
  }
}
