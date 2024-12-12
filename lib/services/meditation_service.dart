import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/mood.dart';
import 'api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/meditation_record.dart';
import 'history_service.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

class MeditationService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  String? _meditationText;
  String? _localAudioPath;
  Uint8List? _audioData;
  bool _isLoading = false;
  BuildContext? _context;

  // 设置 context
  void setContext(BuildContext context) {
    _context = context;
  }

  List<Mood> _predefinedMoods = [
    Mood(id: '1', name: '焦虑'),
    Mood(id: '2', name: '压力'),
    Mood(id: '3', name: '疲惫'),
    Mood(id: '4', name: '困惑'),
    Mood(id: '5', name: '平静'),
    Mood(id: '6', name: '开心'),
  ];

  MeditationService() {
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    print('[Init] 初始化播放器');
    await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    print('[Init] 播放器配置完成');

    _audioPlayer.onPositionChanged.listen((position) {
      print('[Position] ${position.inSeconds}秒');
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      print('[State] ${state.name}');
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      print('[Duration] ${duration.inSeconds}秒');
      _duration = duration;
      notifyListeners();
    });
  }

  Future<void> _downloadAudio(String url) async {
    print('[Download] 开始下载音频');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('[Download] 下载完成');
      _audioData = response.bodyBytes;
      
      if (!kIsWeb) {
        // 移动平台：同时保存到本地文件
        final audioFileName = url.split('/').last;
        final cacheDir = await ApiConfig.getAudioCacheDir();
        await Directory(cacheDir).create(recursive: true);
        _localAudioPath = path.join(cacheDir, audioFileName);
        final file = File(_localAudioPath!);
        await file.writeAsBytes(_audioData!);
        print('[Download] 文件保存到: $_localAudioPath');
        
        // 验证文件
        if (await file.exists()) {
          final fileSize = await file.length();
          print('[Download] 文件大小: $fileSize bytes');
        } else {
          throw Exception('文件保存失败');
        }
      }
    } else {
      throw Exception('下载音频失败');
    }
  }

  Future<void> generateMeditation(String? description) async {
    print('\n[Generate] 开始生成冥想');
    _isLoading = true;
    notifyListeners();

    try {
      final selectedMoods = _predefinedMoods.where((m) => m.isSelected).toList();
      if (selectedMoods.isEmpty) {
        throw Exception('请至少选择一种情绪');
      }

      final result = await _apiService.generateMeditation(
        selectedMoods: selectedMoods,
        description: description,
      );

      _meditationText = result['text'];
      final audioUrl = ApiConfig.backendUrl.replaceAll('/api', '') + result['audio_url'];
      
      print('[Generate] 准备音频: $audioUrl');
      await _downloadAudio(audioUrl);
      
      try {
        if (kIsWeb) {
          await _audioPlayer.setSourceBytes(_audioData!);
          print('[Generate] Web平台音频设置完成');
        } else {
          await _audioPlayer.setSourceDeviceFile(_localAudioPath!);
          print('[Generate] 移动平台音频设置完成: $_localAudioPath');
        }
      } catch (e) {
        print('[Generate] 音频设置错误: $e');
        // 尝试重新设置音频源
        if (!kIsWeb) {
          final file = File(_localAudioPath!);
          if (await file.exists()) {
            try {
              await _audioPlayer.setSourceDeviceFile(_localAudioPath!);
              print('[Generate] 重试音频设置成功');
            } catch (retryError) {
              print('[Generate] 重试音频设置失败: $retryError');
              rethrow;
            }
          } else {
            throw Exception('音频文件不存在');
          }
        }
      }
      
      print('[Generate] 音频设置完成');

      // 创建并保存冥想记录
      if (_context != null) {
        final record = MeditationRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _meditationText!,
          audioPath: kIsWeb ? '' : _localAudioPath!,  // Web平台使用内存中的数据
          timestamp: DateTime.now(),
          moods: selectedMoods.map((m) => m.name).toList(),
          duration: _duration,
        );
        
        await Provider.of<HistoryService>(_context!, listen: false).addRecord(record);
        print('[Generate] 记录已保存');
      }

    } catch (e) {
      print('[Generate] 错误: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清理所有资源
  Future<void> cleanup() async {
    print('\n[Cleanup] 开始清理资源');
    await _audioPlayer.stop();
    _audioData = null;
    _localAudioPath = null;
    _currentPosition = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
    print('[Cleanup] 清理完成');
  }

  Future<void> togglePlay() async {
    if (_audioData == null && _localAudioPath == null) return;

    print('\n[Toggle] 当前状态: ${_isPlaying ? "播放中" : "已暂停"}');

    try {
      if (_isPlaying) {
        print('[Toggle] 执行暂停');
        await _audioPlayer.pause();
      } else {
        print('[Toggle] 执行播放');
        await _audioPlayer.resume();
      }
    } catch (e) {
      print('[Toggle] 错误: $e');
      rethrow;
    }
  }

  // 前进或后退指定秒数
  Future<void> seekRelative(int seconds) async {
    if (_audioData == null && _localAudioPath == null) return;

    final newPosition = Duration(
      seconds: (_currentPosition.inSeconds + seconds).clamp(0, _duration.inSeconds),
    );
    
    print('\n[Seek] ${seconds > 0 ? "前进" : "后退"} $seconds 秒');
    print('[Seek] 从 ${_currentPosition.inSeconds}秒 到 ${newPosition.inSeconds}秒');
    
    await _audioPlayer.seek(newPosition);
  }

  void toggleMood(Mood mood) {
    final index = _predefinedMoods.indexWhere((m) => m.id == mood.id);
    if (index != -1) {
      _predefinedMoods[index].isSelected = !_predefinedMoods[index].isSelected;
      notifyListeners();
    }
  }

  // Getters
  List<Mood> get predefinedMoods => _predefinedMoods;
  String? get meditationText => _meditationText;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  Duration get position => _currentPosition;
  Duration get duration => _duration;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}