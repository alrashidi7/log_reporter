import 'package:log_reporter/app_log_reporter.dart';

/// What action should be taken for this issue
enum DecisionAction {
  ignore, // Do nothing
  includeInDaily, // Include in daily report only
  notifyNow, // Send instant alert
}

/// Severity level (used for reasoning & future extensions)
enum IssueSeverity { low, medium, critical }

/// Decision output
class DecisionResult {
  final DecisionAction action;
  final IssueSeverity severity;
  final String reason;
  final bool shouldDeduplicate;

  const DecisionResult({
    required this.action,
    required this.severity,
    required this.reason,
    required this.shouldDeduplicate,
  });
}

/// The brain 🧠
class DecisionEngine {
  final LogReporterConfig config;

  DecisionEngine({required this.config});
  evaluate() async {
    DateTime dateNow = DateTime.now();
    DateTime yesterDayDate = dateNow.subtract(Duration(days: 1));
    var history = AppLogReporter.talker.history;
    var yesterDayList = history.where(
      (element) => element.time == yesterDayDate,
    );
    var logs = groupApi(history);
    bool haveLogCritical = false;
    for (var api in logs) {
      // ─────────────────────────────────────────────
      // 1️⃣ IGNORE RULES (Scenario D)
      // ─────────────────────────────────────────────
      if (api.totalErrors == 1) {
        haveLogCritical = false;
        // return const DecisionResult(
        //   action: DecisionAction.ignore,
        //   severity: IssueSeverity.low,
        //   reason: 'Single network-related failure',
        //   shouldDeduplicate: false,
        // );
      }
      // ─────────────────────────────────────────────
      // 2️⃣ CRITICAL RULES (Immediate alert)
      // ─────────────────────────────────────────────
      if (api.screens.length > 2) {
        haveLogCritical = true;
        // return DecisionResult(
        //   action: DecisionAction.notifyNow,
        //   severity: IssueSeverity.critical,
        //   reason: 'Client–server contract or parsing failure',
        //   shouldDeduplicate: true,
        // );
      }
      // ─────────────────────────────────────────────
      // 4️⃣ DEFAULT (Ignore)
      // ─────────────────────────────────────────────
      haveLogCritical = false;
      // return const DecisionResult(
      //   action: DecisionAction.ignore,
      //   severity: IssueSeverity.low,
      //   reason: 'Non-critical, non-repeating issue',
      //   shouldDeduplicate: false,
      // );
    }
    if (haveLogCritical || yesterDayList.isNotEmpty) {
      await SmartEmailReporter().sendReport(config: config);
    }
  }
}
