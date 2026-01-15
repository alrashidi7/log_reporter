import 'package:talker_flutter/talker_flutter.dart';
import 'reporter_config.dart';

class AppLogReporter {
  static late Talker _talker;
  static late LogReporterConfig _config;

  static void init(LogReporterConfig config) {
    _config = config;

    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: config.enableLogs,
        useHistory: true,
        maxHistoryItems: config.maxHistoryItems,
      ),
    );
  }

  static Talker get talker => _talker;
  static LogReporterConfig get config => _config;
}
