import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meditation_service.dart';
import '../services/history_service.dart';
import 'meditation_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MeditationService, HistoryService>(
      builder: (context, meditationService, historyService, child) {
        meditationService.setContext(context);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('冥想助手'),
          ),
          body: Material(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 心情选择部分
                    Wrap(
                      spacing: 8.0,
                      children: meditationService.predefinedMoods.map((mood) {
                        return FilterChip(
                          label: Text(mood.name),
                          selected: mood.isSelected,
                          onSelected: (bool selected) {
                            meditationService.toggleMood(mood);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // 描述输入框
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: '或者详细描述一下你的感受...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // 开始冥想按钮
                    ElevatedButton(
                      onPressed: meditationService.isLoading
                        ? null
                        : () async {
                            try {
                              await meditationService.generateMeditation(
                                _descriptionController.text,
                              );
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MeditationPlayerScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                      child: meditationService.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('开始冥想'),
                    ),

                    const SizedBox(height: 32),
                    
                    // 历史记录标题
                    const Text(
                      '冥想记录',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 历史记录列表
                    if (historyService.records.isEmpty)
                      const Center(
                        child: Text('暂无冥想记录'),
                      )
                    else
                      ...historyService.records.map((record) => Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(record.title ?? '未命名冥想'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('时长: ${record.duration.inMinutes}分钟'),
                              Text('心情: ${record.moods.join(", ")}'),
                              Text('时间: ${record.timestamp.toString().substring(0, 16)}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              record.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: record.isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              historyService.toggleFavorite(record.id);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MeditationPlayerScreen(),
                              ),
                            );
                          },
                        ),
                      )).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 