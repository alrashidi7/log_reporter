import 'package:get_it/get_it.dart';
import 'package:log_reporter/app_log_reporter.dart';

final sl = GetIt.instance;

init() async {
  //---------------------------------------------------CORE----------------------------------------------------------------

  sl.registerLazySingleton<ScreenTrackingObserver>(
    () => ScreenTrackingObserver(),
  );
  sl.registerLazySingleton<ApiMetricsInterceptor>(
    () => ApiMetricsInterceptor(sl()),
  );
  sl.registerLazySingleton<LogReporterConfig>(
    () => LogReporterConfig(
      enableEmailReport: true,
      enableFlutterErrorCatching: true,
      enableLogs: true,
    ),
  );
  sl.registerLazySingleton<DailyEmailScheduler>(() => DailyEmailScheduler());
}
