import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../core/reporter.dart';

class AppLogReporterScreen extends StatelessWidget {
  const AppLogReporterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TalkerScreen(talker: AppLogReporter.talker);
  }
}
