import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences.dart';
import '../config/environment_config.dart';
import '../config/api_config.dart';

class VersionService {
  static const String _lastCheckKey = 'last_version_check';
  
  static Future<bool> needsUpdate() async {
    if (!EnvironmentConfig.isTestFlight && !EnvironmentConfig.isProduction) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 检查是否需要更新版本信息
    if (now - lastCheck < EnvironmentConfig.updateCheckInterval.inMilliseconds) {
      return false;
    }
    
    try {
      final currentVersion = await EnvironmentConfig.appVersion;
      final headers = await ApiConfig.headers;
      
      final response = await http.get(
        Uri.parse('${ApiConfig.backendUrl}/version'),
        headers: headers,
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['latest_version'];
        final minVersion = data['min_version'];
        final forceUpdate = data['force_update'] ?? false;
        
        // 保存检查时间
        await prefs.setInt(_lastCheckKey, now);
        
        // 检查版本
        if (forceUpdate && _compareVersions(currentVersion, minVersion) < 0) {
          return true;
        }
        
        if (_compareVersions(currentVersion, latestVersion) < 0) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      if (EnvironmentConfig.enableDetailedLogs) {
        print('[Version] 检查更新失败: $e');
      }
      return false;
    }
  }
  
  static int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();
    
    for (var i = 0; i < 3; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;
      
      if (v1Part < v2Part) return -1;
      if (v1Part > v2Part) return 1;
    }
    
    return 0;
  }
  
  static Future<Map<String, dynamic>> getVersionInfo() async {
    try {
      final headers = await ApiConfig.headers;
      final response = await http.get(
        Uri.parse('${ApiConfig.backendUrl}/version'),
        headers: headers,
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      
      return {};
    } catch (e) {
      if (EnvironmentConfig.enableDetailedLogs) {
        print('[Version] 获取版本信息失败: $e');
      }
      return {};
    }
  }
} 