import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:log_reporter/src/model/screen_log.dart';
import '../core/reporter.dart';

// class ScreenTrackingObserver extends NavigatorObserver {
//   final Map<String, DateTime> _screenStart = {};

//   @override
//   void didPush(Route route, Route? previousRoute) {
//     // Only log MaterialPageRoute (skip dialogs, bottom sheets)
//     if (route is MaterialPageRoute) {
//       final screenName =
//           route.settings.name ?? route.builder.runtimeType.toString();
//       _screenStart[screenName] = DateTime.now();
//       AppLogReporter.talker.info('Screen Opened: $screenName');
//     }
//   }

//   @override
//   void didPop(Route route, Route? previousRoute) {
//     if (route is MaterialPageRoute) {
//       final screenName =
//           route.settings.name ?? route.builder.runtimeType.toString();
//       final startTime = _screenStart.remove(screenName);
//       final duration = startTime != null
//           ? DateTime.now().difference(startTime).inMilliseconds
//           : null;
//       AppLogReporter.talker.info(
//         'Screen Closed: $screenName | Duration: ${duration ?? "unknown"} ms',
//       );
//     }
//   }
// }

class ScreenTrackingObserver extends NavigatorObserver {
  final List<ScreenLog> _screens = [];
  ScreenLog? currentScreen;

  List<ScreenLog> get screens => _screens;

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is MaterialPageRoute) {
      final screenName =
          route.settings.name ?? route.builder.runtimeType.toString();
      if (currentScreen != null && currentScreen!.closedAt == null) {
        currentScreen!.closedAt = DateTime.now();
      }

      currentScreen = ScreenLog(
        screenName: screenName,
        openedAt: DateTime.now(),
      );
      _screens.add(currentScreen!);

      AppLogReporter.talker.info('[Screen Opened] | $screenName');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route is MaterialPageRoute) {
      final screenName =
          route.settings.name ?? route.builder.runtimeType.toString();
      if (currentScreen != null && currentScreen!.screenName == screenName) {
        currentScreen!.closedAt = DateTime.now();

        AppLogReporter.talker.info(
          '[Screen Closed] | $screenName | Duration: ${currentScreen!.durationMs}ms',
        );
      }
      currentScreen = previousRoute is MaterialPageRoute
          ? _screens.lastWhereOrNull(
              (s) =>
                  s.screenName ==
                  (previousRoute.settings.name ??
                      previousRoute.builder.runtimeType.toString()),
            )
          : null;
    }
  }
}
