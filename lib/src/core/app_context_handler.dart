import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class LoggerAppContext {
  static final LoggerAppContext _instance = LoggerAppContext._internal();
  factory LoggerAppContext() => _instance;
  LoggerAppContext._internal();

  bool _initialized = false;

  late Map<String, dynamic> data;

  Future<void> init({required bool isProduction}) async {
    if (_initialized) return;

    final package = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    Map<String, dynamic> deviceData = {};

    if (kIsWeb) {
      final web = await deviceInfo.webBrowserInfo;
      deviceData = {
        'platform': 'Web',
        'browser': web.browserName.name,
        'userAgent': web.userAgent,
      };
    } else if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      deviceData = {
        'platform': 'Android',
        'model': android.model,
        'manufacturer': android.manufacturer,
        'os': 'Android ${android.version.release}',
      };
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      deviceData = {
        'platform': 'iOS',
        'model': ios.utsname.machine,
        'os': 'iOS ${ios.systemVersion}',
      };
    } else {
      deviceData = {'platform': Platform.operatingSystem};
    }

    data = {
      'app_name': package.appName,
      'package_name': package.packageName,
      'version': package.version,
      'build_number': package.buildNumber,
      'environment': isProduction ? 'production' : 'staging',
      'device': deviceData,
      'timezone': DateTime.now().timeZoneName,
      'locale': Intl.getCurrentLocale(),
      'captured_at': DateTime.now().toIso8601String(),
    };

    _initialized = true;
  }

  /// Fetches current network connectivity status (called when building reports)
  Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final connectivityList = results
          .map((r) => r.name)
          .join(', ');
      return {
        'connectivity': connectivityList.isNotEmpty ? connectivityList : 'none',
        'checked_at': DateTime.now().toIso8601String(),
      };
    } catch (_) {
      return {'connectivity': 'unknown', 'error': 'Failed to fetch'};
    }
  }
}
