import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:log_reporter/app_log_reporter.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AppLogReporter {
  // ------------------------------
  // Package fields
  // ------------------------------
  static late Talker _talker;
  static late LogReporterConfig _config;
  static late ScreenTrackingObserver _screenObserver;

  // ------------------------------
  // Initialize package
  // ------------------------------
  static void init({
    required LogReporterConfig config,
    required ScreenTrackingObserver screenObserver,
  }) async {
    _config = config;

    // Initialize Talker with history
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: config.enableLogs,
        useHistory: true,
        maxHistoryItems: config.maxHistoryItems,
      ),
    );
    _screenObserver = screenObserver;

    // Set up Flutter error catching if enabled
    if (_config.enableFlutterErrorCatching) {
      _setupFlutterErrorCatching();
    }
  }

  // ------------------------------
  // Getters
  // ------------------------------
  static Talker get talker => _talker;
  static LogReporterConfig get config => _config;
  static ScreenTrackingObserver get screenObserver => _screenObserver;

  // ------------------------------
  // Flutter Error Catching
  // ------------------------------
  static void _setupFlutterErrorCatching() {
    final FlutterExceptionHandler? defaultOnError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      // Log to Talker
      talker.error(
        '[Flutter Error]-[${screenObserver.currentScreen?.screenName}]- ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );

      // Call default handler or dump to console
      if (defaultOnError != null) {
        defaultOnError(details);
      } else {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // Catch async errors globally
    runZonedGuarded(() {}, (error, stackTrace) {
      final errorLog = ErrorLog(
        exeptionMsg: error.toString(),
        stackTrace: stackTrace,
        type: ErrorLogType.exeption,
        time: null,
        apiLog: null,
        screenLog: null,
      );
      talker.error(
        '[MyAppLog]-[${screenObserver.currentScreen?.screenName}]-[Async Error]',
        error.toString(),
        stackTrace,
      );
    });
  }
}
