import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'environment_config.dart';

class ApiConfig {
  static String get backendUrl {
    return '${EnvironmentConfig.apiBaseUrl}/api';
  }
  
  // 获取音频缓存目录
  static Future<String> getAudioCacheDir() async {
    if (kIsWeb) {
      throw UnsupportedError('Web平台不支持本地文件系统');
    }
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = '${appDir.path}/audio_cache';
    await Directory(cacheDir).create(recursive: true);
    return cacheDir;
  }
}