import 'package:flutter/material.dart';
import 'package:log_reporter/app_log_reporter.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AppLogReporterScreen extends StatelessWidget {
  const AppLogReporterScreen({super.key, required this.reporter});
  final SmartEmailReporter reporter;

  @override
  Widget build(BuildContext context) {
    return TalkerScreen(
      talker: AppLogReporter.talker,
      appBarTitle: AppLogReporter.config.appName,
      appBarLeading: IconButton(
        onPressed: () async {
          await reporter.sendReport();
        },
        icon: Icon(Icons.send_outlined),
      ),
    );
  }
}
