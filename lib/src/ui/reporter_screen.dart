import 'package:flutter/material.dart';
import 'package:log_reporter/app_log_reporter.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AppLogReporterScreen extends StatelessWidget {
  const AppLogReporterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TalkerScreen(
      talker: AppLogReporter.talker,
      appBarTitle: AppLogReporter.config.appName,
    );
  }
}
