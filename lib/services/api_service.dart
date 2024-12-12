import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mood.dart';
import '../config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.backendUrl;

  Future<Map<String, dynamic>> generateMeditation({
    required List<Mood> selectedMoods,
    String? description,
  }) async {
    print('\n=== 发送冥想生成请求 ===');
    print('URL: $baseUrl/meditate');
    print('心情: ${selectedMoods.map((m) => m.name).toList()}');
    print('描述: $description');

    try {
      final client = http.Client();
      final response = await client.post(
        Uri.parse('$baseUrl/meditate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'moods': selectedMoods.map((m) => m.name).toList(),
          'description': description,
        }),
      ).timeout(
        const Duration(minutes: 5),  // 增加到5分钟
        onTimeout: () {
          client.close();
          throw Exception('请求超时，请稍后重试');
        },
      );

      print('\n=== 收到响应 ===');
      print('状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      throw Exception('API调用失败: ${response.statusCode}');
    } catch (e) {
      print('API调用出错: $e');
      rethrow;
    }
  }
} 