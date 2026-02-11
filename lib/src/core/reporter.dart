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
  static late LoggerAppContext _loggerAppContext;
  static SmartEmailReporter? _immediateReporter;

  // ------------------------------
  // Initialize package
  // ------------------------------
  static void init({
    required LogReporterConfig config,
    required ScreenTrackingObserver screenObserver,
    required LoggerAppContext loggerAppContext,
    SmartEmailReporter? immediateReporter,
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

    loggerAppContext.init(isProduction: config.isProduction);

    _loggerAppContext = loggerAppContext;
    _immediateReporter = immediateReporter;

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
  static LoggerAppContext get loggerContext => _loggerAppContext;
  static SmartEmailReporter? get immediateReporter => _immediateReporter;

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

      // Send immediate report for app crashes
      _immediateReporter?.sendImmediateErrorReport(
        errorType: 'App Crash',
        message: details.exceptionAsString(),
        exception: details.exception,
        stackTrace: details.stack,
        screenName: screenObserver.currentScreen?.screenName,
      );

      // Call default handler or dump to console
      if (defaultOnError != null) {
        defaultOnError(details);
      } else {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // Note: For async/zone errors, wrap runApp with runZonedGuarded and use
    // AppLogReporter.zoneErrorHandler. See README.
  }

  /// Use this with runZonedGuarded in main() to catch uncaught async errors:
  /// runZonedGuarded(() async { ... runApp(MyApp()); }, AppLogReporter.zoneErrorHandler);
  static void zoneErrorHandler(Object error, StackTrace stackTrace) {
    talker.error(
      '[MyAppLog]-[${screenObserver.currentScreen?.screenName}]-[Async Error]',
      error.toString(),
      stackTrace,
    );
    _immediateReporter?.sendImmediateErrorReport(
      errorType: 'Async Error',
      message: error.toString(),
      exception: error,
      stackTrace: stackTrace,
      screenName: screenObserver.currentScreen?.screenName,
    );
  }
}
