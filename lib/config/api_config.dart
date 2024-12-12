import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get backendUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isIOS || Platform.isAndroid) {
      // 在 iOS 模拟器中使用特殊的 host
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
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