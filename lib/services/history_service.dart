import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meditation_record.dart';

class HistoryService extends ChangeNotifier {
  final String _storageKey = 'meditation_history';
  List<MeditationRecord> _records = [];
  
  List<MeditationRecord> get records => List.unmodifiable(_records);

  HistoryService() {
    _loadRecords();
  }

  // 加载历史记录
  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      _records = jsonList.map((json) => MeditationRecord.fromJson(json)).toList();
      _records.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // 按时间倒序
      notifyListeners();
    }
  }

  // 保存历史记录
  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_records.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // 添加新记录
  Future<void> addRecord(MeditationRecord record) async {
    _records.insert(0, record); // 添加到列表开头
    await _saveRecords();
    notifyListeners();
  }

  // 删除记录
  Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _saveRecords();
    notifyListeners();
  }

  // 切换收藏状态
  Future<void> toggleFavorite(String id) async {
    final index = _records.indexWhere((r) => r.id == id);
    if (index != -1) {
      _records[index] = _records[index].copyWith(
        isFavorite: !_records[index].isFavorite,
      );
      await _saveRecords();
      notifyListeners();
    }
  }

  // 获取收藏的记录
  List<MeditationRecord> getFavorites() {
    return _records.where((r) => r.isFavorite).toList();
  }

  // 按心情筛选记录
  List<MeditationRecord> filterByMood(String mood) {
    return _records.where((r) => r.moods.contains(mood)).toList();
  }

  // 清空历史记录
  Future<void> clearHistory() async {
    _records.clear();
    await _saveRecords();
    notifyListeners();
  }
} 