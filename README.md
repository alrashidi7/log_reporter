# 📦 App Log Reporter

A **powerful, reusable logging & reporting package for Flutter apps** built on top of **Talker**, **Dio**, and **Cubit**.

`log_reporter` helps you monitor **screen usage**, **API performance**, **failures**, and **user-facing issues**, and generate **daily reports** that can be sent automatically via email.

---

## ✨ Features

- 📊 **Screen analytics**
  - Screen open count
  - Screen load duration
- 🌐 **API monitoring (Dio)**
  - Request duration
  - Failed requests
  - Slow request detection
- 🧠 **Cubit integration**
  - State changes logging
  - Error tracking with stack traces
- 🧾 **Centralized log history**
  - Powered by Talker history
- 📅 **Daily report generator**
- 📤 **Email reporting (optional)**
- 🛠 **Debug UI (Talker screen)**
- ♻️ **Reusable & modular**
  - Designed for multi-app usage

---

## 📦 Installation

-  sl.registerLazySingleton<ScreenTrackingObserver>(
      () => ScreenTrackingObserver());
-  sl.registerLazySingleton<ApiMetricsInterceptor>(
      () => ApiMetricsInterceptor(sl()));

-  sl.registerLazySingleton<LogReporterConfig>(() => LogReporterConfig(
        enableEmailReport: true,
        enableFlutterErrorCatching: true,
        enableLogs: true,
      ));


### Local / Internal Package

```yaml
dependencies:
      log_reporter:
        git:
        url: https://github.com/alrashidi7/log_reporter.git
        ref: main





