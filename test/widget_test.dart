// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/main.dart';
import 'package:provider/provider.dart';
import 'package:meditation_app/services/meditation_service.dart';

void main() {
  testWidgets('App启动测试', (WidgetTester tester) async {
    // 构建我们的应用
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MeditationService(),
        child: const MyApp(),
      ),
    );

    // 验证初始界面标题
    expect(find.text('今天感觉如何？'), findsOneWidget);
    
    // 验证提示文本
    expect(
      find.text('选择你当前的心情，让我们为你创建个性化的冥想引导。'),
      findsOneWidget,
    );

    // 验证预定义的心情选项
    expect(find.text('焦虑'), findsOneWidget);
    expect(find.text('压力'), findsOneWidget);
    expect(find.text('疲惫'), findsOneWidget);

    // 验证输入框提示
    expect(find.text('或者详细描述一下你的感受...'), findsOneWidget);

    // 验证开始冥想按钮
    expect(find.text('开始冥想'), findsOneWidget);

    // 测试心情选择
    await tester.tap(find.text('焦虑'));
    await tester.pump();

    // 测试文本输入
    await tester.enterText(
      find.byType(TextField),
      '我今天感觉很焦虑',
    );
    await tester.pump();
  });
}
