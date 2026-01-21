import 'package:flutter/material.dart';

import 'package:talker_flutter/talker_flutter.dart';

final apiErrorRegex = RegExp(
  r'\[API ERROR-(\w+)\]-\[(.*?)\]-\s*(\/[^\s]+)\s*\((\d+)ms\)',
);

final apiSlowRegex = RegExp(r'\[Slow API-(\w+)\]-\[(.*?)\]- (.*?) - (\d+)ms');

class ScreenImpact {
  int count = 0;
  int maxDuration = 0;
  TalkerData? slowestLog;
}

class ApiImpactSummary {
  final String endpoint;
  final Map<String, ScreenImpact> screens = {};
  int totalErrors = 0;

  ApiImpactSummary(this.endpoint);

  String generateTheApiImpactSummary() {
    final buffer = StringBuffer();

    buffer.writeln('API: $endpoint');
    buffer.writeln('Total Failures: $totalErrors');
    buffer.writeln('Affected Screens: ${screens.length}\n');

    buffer.writeln('Screen Impact:');
    for (final entry in screens.entries) {
      buffer.writeln(
        '• ${entry.key}\n'
        '  - Failures: ${entry.value.count}\n'
        '  - Max Duration: ${entry.value.maxDuration} ms\n',
      );
    }

    // Find slowest failure across all screens
    final slowestLogs = screens.values
        .where((e) => e.slowestLog != null)
        .map((e) => e.slowestLog!)
        .toList();

    if (slowestLogs.isNotEmpty) {
      final slowest = slowestLogs.reduce((a, b) {
        return _extractDuration(a) > _extractDuration(b) ? a : b;
      });

      buffer.writeln('Slowest Failure Details:');
      buffer.writeln('Screen: ${_extractScreen(slowest)}');
      buffer.writeln('Duration: ${_extractDuration(slowest)} ms');
      buffer.writeln('Time: ${slowest.time}');

      if (slowest.exception != null) {
        buffer.writeln('\nException:');
        buffer.writeln(slowest.exception.toString());
      }
    }

    return buffer.toString();
  }

  int _extractDuration(TalkerData log) {
    final match = apiErrorRegex.firstMatch(log.message ?? '');
    return match != null ? int.parse(match.group(4)!) : 0;
  }

  String _extractScreen(TalkerData log) {
    final match = apiErrorRegex.firstMatch(log.message ?? '');
    return match != null ? match.group(2)! : 'Unknown';
  }
}

List<ApiImpactSummary> groupApi(List<TalkerData> errorLogs) {
  final Map<String, ApiImpactSummary> result = {};

  for (final log in errorLogs) {
    final message = log.message ?? '';
    final match = apiErrorRegex.firstMatch(message);
    if (match == null) {
      debugPrint('❌ NOT MATCHED:\n$message\n');
      continue;
    } else {
      final screen = match.group(2)!;
      final endpoint = match.group(3)!;
      final duration = int.parse(match.group(4)!);
      final apiSummary = result.putIfAbsent(
        endpoint,
        () => ApiImpactSummary(endpoint),
      );

      apiSummary.totalErrors++;

      final screenImpact = apiSummary.screens.putIfAbsent(
        screen,
        () => ScreenImpact(),
      );

      screenImpact.count++;

      // Track slowest per screen
      if (duration > screenImpact.maxDuration) {
        screenImpact.maxDuration = duration;
        screenImpact.slowestLog = log;
      }
    }
  }
  List<ApiImpactSummary> list = [];
  list = result.values.toList();
  return list;
}
