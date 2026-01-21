import 'package:flutter/material.dart';
import 'package:log_reporter/app_log_reporter.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  final LogReporterConfig config;

  AppLifecycleHandler({required this.config});
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await DecisionEngine(config: config).evaluate();
    }
  }
}
