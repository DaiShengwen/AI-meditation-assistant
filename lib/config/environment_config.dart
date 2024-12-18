import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum Environment {
  development,
  production
}

class EnvironmentConfig {
  static Environment get current {
    final env = const String.fromEnvironment('APP_ENV', defaultValue: 'development');
    print('当前环境参数 APP_ENV: $env');
    return env == 'production' ? Environment.production : Environment.development;
  }
  
  static bool get isProduction =>
      current == Environment.production;
      
  static bool get isDevelopment =>
      current == Environment.development;

  // API配置
  static String get apiBaseUrl {
    final url = switch (current) {
      Environment.production => 'http://116.136.130.168:32405',
      Environment.development => kIsWeb ? 'http://localhost:8000' : 'http://127.0.0.1:8000'
    };
    print('使用API地址: $url');
    return url;
  }

  // 版本信息
  static Future<String> get appVersion async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> get buildNumber async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  // 设备信息
  static Future<Map<String, dynamic>> get deviceInfo async {
    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return {
        'platform': 'web',
        'browserName': webInfo.browserName,
        'userAgent': webInfo.userAgent,
      };
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'platform': 'ios',
        'model': iosInfo.model,
        'systemVersion': iosInfo.systemVersion,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
      };
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'model': androidInfo.model,
        'version': androidInfo.version.release,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
      };
    }

    return {
      'platform': defaultTargetPlatform.toString(),
    };
  }

  // 缓存配置
  static Duration get cacheDuration {
    switch (current) {
      case Environment.production:
        return const Duration(days: 7);
      case Environment.development:
        return const Duration(hours: 1);
    }
  }

  // 网络超时配置
  static Duration get connectionTimeout {
    switch (current) {
      case Environment.production:
        return const Duration(seconds: 30);
      case Environment.development:
        return const Duration(minutes: 1);
    }
  }

  // 日志配置
  static bool get enableDetailedLogs {
    return !isProduction;
  }

  // 检查更新配置
  static Duration get updateCheckInterval {
    switch (current) {
      case Environment.production:
        return const Duration(days: 1);
      case Environment.development:
        return const Duration(minutes: 30);
    }
  }
} 