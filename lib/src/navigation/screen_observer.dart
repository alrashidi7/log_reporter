import 'package:flutter/material.dart';
import '../core/reporter.dart';

class ScreenTrackingObserver extends NavigatorObserver {
  DateTime? _enterTime;

  @override
  void didPush(Route route, Route? previousRoute) {
    _enterTime = DateTime.now();

    AppLogReporter.talker.info(
      'Screen Opened: ${route.settings.name ?? route.runtimeType.toString()}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (_enterTime == null) return;

    final duration = DateTime.now().difference(_enterTime!).inMilliseconds;

    AppLogReporter.talker.info(
      'Screen Closed: ${route.settings.name ?? route.runtimeType.toString()} (${duration}ms)',
    );
  }
}
