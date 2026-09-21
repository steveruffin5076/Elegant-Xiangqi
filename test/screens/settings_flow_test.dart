import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:elegant_xiangqi/game/campaign_progress.dart';
import 'package:elegant_xiangqi/main.dart';
import 'package:elegant_xiangqi/screens/home_screen.dart';
import 'package:elegant_xiangqi/screens/settings_screen.dart';
import 'package:elegant_xiangqi/theme/palette.dart';
import 'package:elegant_xiangqi/theme/theme_controller.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('settings_flow_test');
    Hive.init(tempDir.path);
    await CampaignProgress.init();
  });

  tearDown(() async {
    // Not resetting themeController here on purpose: this file has a
    // single test, so there's no cross-test contamination risk, and a
    // redundant setTheme() call here previously raced the tap's own
    // fire-and-forget Hive write, deadlocking Hive.deleteFromDisk().
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  testWidgets('menu -> theme -> selecting Obsidian updates the UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElegantXiangqiApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('菜单'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.textContaining('主题'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    // Default selection is Huanghuali & Jade.
    expect(find.text(huanghualiJade.name), findsOneWidget);
    expect(find.text(obsidianMoonlight.name), findsOneWidget);

    await tester.tap(find.text(obsidianMoonlight.name));
    await tester.pumpAndSettle();

    expect(themeController.theme, AppTheme.obsidianMoonlight);
    final selectedTile = find.ancestor(
      of: find.text(obsidianMoonlight.name),
      matching: find.byType(Row),
    );
    expect(
      find.descendant(
        of: selectedTile,
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });
}
