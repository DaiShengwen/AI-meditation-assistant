import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/history_service.dart';
import '../models/meditation_record.dart';
import 'meditation_player_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryService>(
      builder: (context, historyService, child) {
        final records = historyService.records;
        
        if (records.isEmpty) {
          return const Center(
            child: Text('暂无冥想记录'),
          );
        }

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildHistoryItem(context, record);
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, MeditationRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                record.moods.join(', '),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(
                record.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: record.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                context.read<HistoryService>().toggleFavorite(record.id);
              },
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              record.text.length > 50 
                  ? '${record.text.substring(0, 50)}...' 
                  : record.text,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(record.timestamp),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Text(
          '${record.duration.inMinutes}分钟',
          style: const TextStyle(color: Colors.blue),
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
    );
  }
} 