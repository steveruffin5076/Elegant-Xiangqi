import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:elegant_xiangqi/theme/palette.dart';
import 'package:elegant_xiangqi/theme/theme_controller.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('theme_controller_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('defaults to Huanghuali & Jade', () {
    final controller = ThemeController();
    expect(controller.theme, AppTheme.huanghualiJade);
    expect(controller.palette, huanghualiJade);
  });

  test('setTheme updates the palette and notifies listeners', () async {
    final controller = ThemeController();
    var notified = false;
    controller.addListener(() => notified = true);

    await controller.setTheme(AppTheme.obsidianMoonlight);

    expect(controller.theme, AppTheme.obsidianMoonlight);
    expect(controller.palette, obsidianMoonlight);
    expect(notified, isTrue);
  });

  test('setTheme persists across a fresh controller via loadSaved', () async {
    final first = ThemeController();
    await first.setTheme(AppTheme.imperialScroll);

    final second = ThemeController();
    await second.loadSaved();

    expect(second.theme, AppTheme.imperialScroll);
  });

  test('setTheme with the same theme is a no-op (no notification)', () async {
    final controller = ThemeController(initial: AppTheme.obsidianMoonlight);
    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    await controller.setTheme(AppTheme.obsidianMoonlight);

    expect(notifyCount, 0);
  });
}
