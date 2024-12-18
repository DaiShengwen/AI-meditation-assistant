import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meditation_app/config/api_config.dart';
import 'dart:async';

void main() {
  group('后端API测试', () {
    final baseUrl = 'http://116.136.130.168:32405';
    
    test('测试健康检查端点', () async {
      final url = '$baseUrl/health';
      try {
        print('正在尝试连接健康检查端点: $url');
        final response = await http.get(
          Uri.parse(url),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('健康检查请求超时（10秒）');
          },
        );
        
        print('健康检查响应状态码: ${response.statusCode}');
        print('健康检查响应头: ${response.headers}');
        print('健康检查响应内容: ${response.body}');
        
        expect(response.statusCode, equals(200));
      } catch (e) {
        print('健康检查错误类型: ${e.runtimeType}');
        print('健康检查错误详情: $e');
        fail('健康检查失败: $e');
      }
    });

    test('测试API端点', () async {
      final url = '$baseUrl/api';
      try {
        print('正在尝试连接API端点: $url');
        final response = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('API请求超时（10秒）');
          },
        );
        
        print('API响应状态码: ${response.statusCode}');
        print('API响应头: ${response.headers}');
        print('API响应内容: ${response.body}');
        
        expect(response.statusCode, isIn([200, 404]));
      } catch (e) {
        print('API错误类型: ${e.runtimeType}');
        print('API错误详情: $e');
        print('请检查：');
        print('1. 后端服务是否正在运行（已确认）');
        print('2. 端口32405是否开放（需要检查）');
        print('3. 防火墙是否允许访问（需要检查）');
        print('4. 服务器网络是否正常（需要检查）');
        fail('无法连接到API: $e');
      }
    });
  });
} 