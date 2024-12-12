import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meditation_service.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        elevation: 0,
      ),
      body: Consumer<MeditationService>(
        builder: (context, service, child) {
          return ListView(
            children: [
              _buildSection(
                title: '音频设置',
                children: [
                  _buildVolumeSlider(service),
                  _buildVoiceSelector(service),
                ],
              ),
              _buildSection(
                title: '背景音乐',
                children: [
                  _buildBackgroundMusicSelector(service),
                  _buildBackgroundVolumeSlider(service),
                ],
              ),
              _buildSection(
                title: '主题设置',
                children: [
                  _buildThemeSelector(context),
                ],
              ),
              _buildSection(
                title: '其他',
                children: [
                  _buildCacheCleaner(context),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        Divider(),
      ],
    );
  }

  Widget _buildVolumeSlider(MeditationService service) {
    return ListTile(
      title: Text('音量'),
      subtitle: Slider(
        value: 1.0, // TODO: 从service获取实际值
        onChanged: (value) {
          // TODO: 实现音量调节
        },
      ),
    );
  }

  Widget _buildVoiceSelector(MeditationService service) {
    return ListTile(
      title: Text('语音选择'),
      subtitle: DropdownButton<String>(
        value: 'zh-CN-Standard-A',
        isExpanded: true,
        items: [
          DropdownMenuItem(value: 'zh-CN-Standard-A', child: Text('女声1')),
          DropdownMenuItem(value: 'zh-CN-Standard-B', child: Text('男声1')),
          DropdownMenuItem(value: 'zh-CN-Standard-C', child: Text('女声2')),
        ],
        onChanged: (value) {
          // TODO: 实现语音切换
        },
      ),
    );
  }

  Widget _buildBackgroundMusicSelector(MeditationService service) {
    return ListTile(
      title: Text('背景音乐'),
      subtitle: DropdownButton<String>(
        value: 'none',
        isExpanded: true,
        items: [
          DropdownMenuItem(value: 'none', child: Text('无')),
          DropdownMenuItem(value: 'rain', child: Text('雨声')),
          DropdownMenuItem(value: 'waves', child: Text('海浪')),
          DropdownMenuItem(value: 'forest', child: Text('森林')),
        ],
        onChanged: (value) {
          // TODO: 实现背景音乐切换
        },
      ),
    );
  }

  Widget _buildBackgroundVolumeSlider(MeditationService service) {
    return ListTile(
      title: Text('背景音量'),
      subtitle: Slider(
        value: 0.5, // TODO: 从service获取实际值
        onChanged: (value) {
          // TODO: 实现背景音量调节
        },
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return ListTile(
      title: Text('主题'),
      trailing: Icon(Icons.brightness_6),
      onTap: () {
        // TODO: 实现主题切换
      },
    );
  }

  Widget _buildCacheCleaner(BuildContext context) {
    return ListTile(
      title: Text('清除缓存'),
      trailing: Icon(Icons.cleaning_services),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确认清除'),
            content: Text('这将清除所有缓存的音频文件，确定继续吗？'),
            actions: [
              TextButton(
                child: Text('取消'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('确定'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // TODO: 实现缓存清理
        }
      },
    );
  }
} 