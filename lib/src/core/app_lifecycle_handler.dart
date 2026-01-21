import 'package:flutter/material.dart';
import 'package:log_reporter/app_log_reporter.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  final LogReporterConfig config;
  final SmartEmailReporter reporter;

  AppLifecycleHandler({required this.config, required this.reporter});
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await DecisionEngine(config: config, reporter: reporter).evaluate();
    }
  }
}
