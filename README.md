# 📦 App Log Reporter

A **powerful, reusable logging & reporting package for Flutter apps** built on top of **Talker**, **Dio**, and **Cubit**.

`log_reporter` helps you monitor **screen usage**, **API performance**, **errors**, and **user-facing issues**, then intelligently generates **daily or critical reports** that can be sent automatically via email.

Designed to be **plug-and-play**, **production-safe**, and **reusable across multiple apps**.

---

## ✨ Features

### 📊 Screen Analytics
- Screen open count
- Screen visible duration
- Screen impact tracking

### 🌐 API Monitoring (Dio)
- API duration tracking
- Slow API detection (configurable threshold)
- Failed request logging
- Status code filtering (e.g. ignore 401 / 403)

### 🧠 State & Error Tracking
- Cubit state change logging
- Flutter framework error capture
- Stack trace & exception body logging

### 🧾 Centralized Log History
- Powered by **Talker**
- In-memory history with configurable size
- Optimized for batch processing

### 📬 Smart Email Reporting
- Daily summary reports
- Critical issue detection
- Deduplication logic
- Avoids spam (network & one-time issues ignored)
- Sends only when user actually faced a problem

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


sl.registerLazySingleton<AppLogReporter>(() => AppLogReporter());

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

sl.registerLazySingleton<AppLifecycleHandler>(
  () => AppLifecycleHandler(
    config: sl(),
    reporter: sl(),
  ),
);