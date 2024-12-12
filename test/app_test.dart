import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/screens/meditation_player_screen.dart';
import 'package:meditation_app/screens/mood_selection_screen.dart';
import 'package:meditation_app/services/meditation_service.dart';
import 'package:provider/provider.dart';

void main() {
  group('冥想App测试', () {
    testWidgets('冥想播放界面测试', (WidgetTester tester) async {
      // 构建测试环境
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MeditationService(),
          child: MaterialApp(
            home: MeditationPlayerScreen(),
          ),
        ),
      );

      // 测试UI元素是否存在
      expect(find.text('正在冥想'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      
      // 测试播放按钮交互
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      
      // 测试进度条
      expect(find.byType(Slider), findsOneWidget);
      
      // 测试音频控制按钮
      expect(find.byIcon(Icons.replay_10), findsOneWidget);
      expect(find.byIcon(Icons.forward_10), findsOneWidget);
    });

    testWidgets('心情选择测试', (WidgetTester tester) async {
      // 构建测试环境
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MeditationService(),
          child: MaterialApp(
            home: MoodSelectionScreen(),
          ),
        ),
      );

      // 测试心情选项
      expect(find.text('焦虑'), findsOneWidget);
      expect(find.text('压力'), findsOneWidget);
      
      // 测试选择心情
      await tester.tap(find.text('焦虑'));
      await tester.pump();
      
      // 测试开始按钮
      expect(find.text('开始冥想'), findsOneWidget);
    });
  });
} 