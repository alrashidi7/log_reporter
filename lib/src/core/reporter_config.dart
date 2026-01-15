class LogReporterConfig {
  final bool enableLogs;
  final int slowApiThresholdMs;
  final int maxHistoryItems;
  final bool enableEmailReport;
  final bool enableFlutterErrorCatching;

  const LogReporterConfig({
    this.enableLogs = true,
    this.enableFlutterErrorCatching = false,
    this.slowApiThresholdMs = 1500,
    this.maxHistoryItems = 5000,
    this.enableEmailReport = false,
  });
}
