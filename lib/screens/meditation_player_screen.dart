import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meditation_service.dart';

class MeditationPlayerScreen extends StatelessWidget {
  const MeditationPlayerScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await context.read<MeditationService>().cleanup();
        return true;
      },
      child: Consumer<MeditationService>(
        builder: (context, service, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('冥想播放'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await service.cleanup();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 进度条和时间显示
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // 时间显示
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(service.position)),
                          Text(_formatDuration(service.duration)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 进度条
                      LinearProgressIndicator(
                        value: service.duration.inSeconds > 0
                            ? service.position.inSeconds / service.duration.inSeconds
                            : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 播放控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 后退10秒按钮
                    IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.replay_10),
                      onPressed: () => service.seekRelative(-10),
                    ),
                    const SizedBox(width: 16),
                    // 播放/暂停按钮
                    IconButton(
                      iconSize: 48,
                      icon: Icon(
                        service.isPlaying 
                          ? Icons.pause_circle_filled 
                          : Icons.play_circle_filled,
                      ),
                      onPressed: service.togglePlay,
                    ),
                    const SizedBox(width: 16),
                    // 前进10秒按钮
                    IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.forward_10),
                      onPressed: () => service.seekRelative(10),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 