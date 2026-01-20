class LogReporterConfig {
  final bool enableLogs;
  final int slowApiThresholdMs;
  final int maxHistoryItems;
  final bool enableEmailReport;
  final bool enableFlutterErrorCatching;

  final String smtpEmail;
  final String appPassword;
  final String toEmail;
  final String appName;
  final bool isProduction;

  const LogReporterConfig({
    required this.enableLogs,
    this.enableFlutterErrorCatching = false,
    this.slowApiThresholdMs = 1500,
    this.maxHistoryItems = 5000,
    this.enableEmailReport = false,
    required this.appName,
    required this.appPassword,
    required this.isProduction,
    required this.smtpEmail,
    required this.toEmail,
  });
}
