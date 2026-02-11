## 0.0.2

### Changed
- **Breaking:** Switched from daily report to immediate error reporting
- API errors and app crashes are now sent to email immediately (when `enableEmailReport` is true and `immediateReporter` is passed to `AppLogReporter.init`)
- Reports now include network connectivity information
- `AppLogReporter.init()` accepts optional `immediateReporter` parameter for email alerts

### Added
- `ImmediateErrorReportBuilder` for building single-error reports with device, network, app version, and trace
- `SmartEmailReporter.sendImmediateErrorReport()` for sending immediate alerts
- `AppLogReporter.zoneErrorHandler` for use with `runZonedGuarded` to catch async errors
- `connectivity_plus` dependency for network info in reports

### Removed
- `DecisionEngine`, `AppLifecycleHandler` (daily report triggers)
- `SmartDailyReportBuilder`, `ApiImpactSummary`
- Manual send button from `AppLogReporterScreen` (now shows Talker screen only)

---

## 0.0.1

* Initial release with daily report system.
