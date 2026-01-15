class LogReporterConfig {
  final bool enableLogs;
  final int slowApiThresholdMs;
  final int maxHistoryItems;
  final bool enableEmailReport;

  const LogReporterConfig({
    this.enableLogs = true,
    this.slowApiThresholdMs = 1500,
    this.maxHistoryItems = 5000,
    this.enableEmailReport = false,
  });
}
