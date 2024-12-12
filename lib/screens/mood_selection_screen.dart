import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meditation_service.dart';

class MoodSelectionScreen extends StatelessWidget {
  const MoodSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择心情'),
      ),
      body: Consumer<MeditationService>(
        builder: (context, service, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (var mood in service.predefinedMoods)
                ListTile(
                  title: Text(mood.name),
                  trailing: Checkbox(
                    value: mood.isSelected,
                    onChanged: (_) => service.toggleMood(mood.id),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await service.generateMeditation(null);
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/player');
                  }
                },
                child: const Text('开始冥想'),
              ),
            ],
          );
        },
      ),
    );
  }
} 