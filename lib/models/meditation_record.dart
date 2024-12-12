import 'package:flutter/foundation.dart';

class MeditationRecord {
  final String id;
  final String text;
  final String audioPath;
  final DateTime timestamp;
  final List<String> moods;
  final Duration duration;
  final bool isFavorite;
  final String? title;

  MeditationRecord({
    required this.id,
    required this.text,
    required this.audioPath,
    required this.timestamp,
    required this.moods,
    required this.duration,
    this.isFavorite = false,
    this.title,
  });

  // 从 JSON 创建记录
  factory MeditationRecord.fromJson(Map<String, dynamic> json) {
    return MeditationRecord(
      id: json['id'],
      text: json['text'],
      audioPath: json['audio_path'],
      timestamp: DateTime.parse(json['timestamp']),
      moods: List<String>.from(json['moods']),
      duration: Duration(seconds: json['duration_seconds']),
      isFavorite: json['is_favorite'] ?? false,
      title: json['title'] as String?,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'audio_path': audioPath,
      'timestamp': timestamp.toIso8601String(),
      'moods': moods,
      'duration_seconds': duration.inSeconds,
      'is_favorite': isFavorite,
      'title': title,
    };
  }

  // 创建副本并修改某些字段
  MeditationRecord copyWith({
    String? id,
    String? text,
    String? audioPath,
    DateTime? timestamp,
    List<String>? moods,
    Duration? duration,
    bool? isFavorite,
    String? title,
  }) {
    return MeditationRecord(
      id: id ?? this.id,
      text: text ?? this.text,
      audioPath: audioPath ?? this.audioPath,
      timestamp: timestamp ?? this.timestamp,
      moods: moods ?? this.moods,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      title: title ?? this.title,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          audioPath == other.audioPath &&
          timestamp == other.timestamp &&
          listEquals(moods, other.moods) &&
          duration == duration &&
          isFavorite == isFavorite &&
          title == title;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      audioPath.hashCode ^
      timestamp.hashCode ^
      moods.hashCode ^
      duration.hashCode ^
      isFavorite.hashCode ^
      title.hashCode;

  @override
  String toString() =>
      'MeditationRecord(id: $id, title: $title, moods: $moods, duration: $duration)';
} 