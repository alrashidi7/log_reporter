import 'package:flutter/material.dart';
import '../core/reporter.dart';

class ScreenTrackingObserver extends NavigatorObserver {
  final Map<String, DateTime> _screenStart = {};

  @override
  void didPush(Route route, Route? previousRoute) {
    // Only log MaterialPageRoute (skip dialogs, bottom sheets)
    if (route is MaterialPageRoute) {
      final screenName =
          route.settings.name ?? route.builder.runtimeType.toString();
      _screenStart[screenName] = DateTime.now();
      AppLogReporter.talker.info('Screen Opened: $screenName');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route is MaterialPageRoute) {
      final screenName =
          route.settings.name ?? route.builder.runtimeType.toString();
      final startTime = _screenStart.remove(screenName);
      final duration = startTime != null
          ? DateTime.now().difference(startTime).inMilliseconds
          : null;
      AppLogReporter.talker.info(
        'Screen Closed: $screenName | Duration: ${duration ?? "unknown"} ms',
      );
    }
  }
}
