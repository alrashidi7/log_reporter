# 📦 App Log Reporter

A **powerful, reusable logging & reporting package for Flutter apps** built on top of **Talker** and **Dio**.

`log_reporter` helps you monitor **screen usage**, **API performance**, and **errors**, then **sends immediate email alerts** when users face critical issues (API errors, app crashes).

Designed to be **plug-and-play**, **production-safe**, and **reusable across multiple apps**.

---

## ✨ Features

### 📊 Screen Analytics
- Screen open count
- Screen visible duration

### 🌐 API Monitoring (Dio)
- API duration tracking
- Slow API detection (configurable threshold)
- Failed request logging with **immediate email alert**
- Status code filtering (e.g. ignore 401 / 403)

### 🚨 Immediate Error Reporting
- **API errors** → Sent to email instantly with full context
- **App crashes** (Flutter errors) → Sent immediately
- **Async errors** → Use `zoneErrorHandler` with `runZonedGuarded`
- Each report includes: device info, network info, app version, error trace

### 🧾 Centralized Log History
- Powered by **Talker**
- In-memory history with configurable size

### 🛠 Debug Tools
- Talker debug screen (optional)
- Console logging (dev only)

### ♻️ Modular & Reusable
- Clean architecture friendly
- Works with `get_it`
- Can be shipped as an internal SDK

---

## 📦 Installation

### Local / Internal Git Package

```yaml
dependencies:
  log_reporter:
    git:
      url: https://github.com/alrashidi7/log_reporter.git
      ref: main


sl.registerLazySingleton<ScreenTrackingObserver>(
  () => ScreenTrackingObserver(),
);

sl.registerLazySingleton<ApiMetricsInterceptor>(
  () => ApiMetricsInterceptor(
    sl(),
    statusCodeIgnore: [401, 403],
  ),
);

sl.registerLazySingleton<LogReporterConfig>(
  () => LogReporterConfig(
    enableLogs: true,
    slowApiThresholdMs: 4000,
    enableFlutterErrorCatching: true,
    maxHistoryItems: 5000,
    enableEmailReport: true,

    // Email config
    smtpEmail: '',
    appPassword: '',
    toEmail: '',
    appName: '',

    isProduction: false,
  ),
);

sl.registerLazySingleton<LoggerAppContext>(
  () => LoggerAppContext(),
);

sl.registerLazySingleton<SmartEmailReporter>(
  () => SmartEmailReporter(
    config: sl(),
    loggerAppContext: sl(),
  ),
);

// Initialize (call after DI setup, before runApp)
void setupLogReporter() async {
  await AppLogReporter.init(
    config: sl(),
    screenObserver: sl(),
    loggerAppContext: sl(),
    immediateReporter: sl(), // Enables immediate email alerts
  );
}

// In main() - wrap runApp to catch async errors:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup(); // your get_it setup
  await setupLogReporter();

  runZonedGuarded(
    () => runApp(MyApp()),
    AppLogReporter.zoneErrorHandler,
  );
}