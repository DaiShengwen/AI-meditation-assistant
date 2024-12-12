import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meditation_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('完整流程测试', () {
    testWidgets('从选择心情到完成冥想', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. 选择心情
      await tester.tap(find.text('焦虑'));
      await tester.pumpAndSettle();

      // 2. 点击开始冥想
      await tester.tap(find.text('开始冥想'));
      await tester.pumpAndSettle();

      // 3. 等待生成文本和音频
      await tester.pump(Duration(seconds: 5));

      // 4. 测试播放控制
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // 5. 测试进度条拖动
      final Offset sliderLocation = tester.getCenter(find.byType(Slider));
      await tester.dragFrom(sliderLocation, Offset(100, 0));
      await tester.pumpAndSettle();
    });
  });
} 