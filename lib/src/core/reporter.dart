import 'package:flutter/foundation.dart';
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

    if (_config.enableFlutterErrorCatching) {
      _setupFlutterErrorCatching();
    }
  }

  static Talker get talker => _talker;
  static LogReporterConfig get config => _config;
  static void _setupFlutterErrorCatching() {
    // Save the previous handler to not break Flutter defaults
    final FlutterExceptionHandler? defaultOnError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      // Log the error to Talker
      talker.error(details.exceptionAsString(), {
        'type': 'flutter_framework_error',
        'time': DateTime.now().toIso8601String(),
      }, details.stack);

      // Optionally, still call the default Flutter error handler
      if (defaultOnError != null) {
        defaultOnError(details);
      } else {
        FlutterError.dumpErrorToConsole(details);
      }
    };
  }
}
