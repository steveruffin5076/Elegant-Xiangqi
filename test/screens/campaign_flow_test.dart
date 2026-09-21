import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:elegant_xiangqi/game/campaign_data.dart';
import 'package:elegant_xiangqi/game/campaign_progress.dart';
import 'package:elegant_xiangqi/main.dart';
import 'package:elegant_xiangqi/screens/campaign_map_screen.dart';
import 'package:elegant_xiangqi/screens/game_screen.dart';
import 'package:elegant_xiangqi/screens/home_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('campaign_flow_test');
    Hive.init(tempDir.path);
    await CampaignProgress.init();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  testWidgets(
    'menu -> campaign map: unlocked level opens the game, locked level does not',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ElegantXiangqiApp());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.textContaining('闯关模式'));
      await tester.pumpAndSettle();
      expect(find.byType(CampaignMapScreen), findsOneWidget);

      // Level 2 (id "1-2") is locked on a fresh install — tapping it does
      // nothing.
      await tester.tap(find.text('2').first);
      await tester.pumpAndSettle();
      expect(find.byType(CampaignMapScreen), findsOneWidget);
      expect(find.byType(GameScreen), findsNothing);

      // The first level node is always unlocked.
      final level1 = allCampaignLevels.first;
      await tester.tap(find.text('1').first);
      await tester.pumpAndSettle();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.text(level1.title), findsOneWidget);
    },
  );
}
