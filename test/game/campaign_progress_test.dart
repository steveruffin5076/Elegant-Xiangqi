import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:elegant_xiangqi/game/campaign_progress.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('campaign_progress_test');
    Hive.init(tempDir.path);
    await CampaignProgress.init();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('a fresh install has only level 0 unlocked and no stars', () {
    expect(CampaignProgress.unlockedCount, 1);
    expect(CampaignProgress.isUnlocked(0), isTrue);
    expect(CampaignProgress.isUnlocked(1), isFalse);
    expect(CampaignProgress.starsFor('1-1'), 0);
  });

  test('winning a level records stars and unlocks the next one', () async {
    await CampaignProgress.recordResult(
      levelId: '1-1',
      overallIndex: 0,
      stars: 3,
    );

    expect(CampaignProgress.starsFor('1-1'), 3);
    expect(CampaignProgress.unlockedCount, 2);
    expect(CampaignProgress.isUnlocked(1), isTrue);
    expect(CampaignProgress.isUnlocked(2), isFalse);
  });

  test('a worse replay never lowers the recorded star count', () async {
    await CampaignProgress.recordResult(
      levelId: '1-1',
      overallIndex: 0,
      stars: 3,
    );
    await CampaignProgress.recordResult(
      levelId: '1-1',
      overallIndex: 0,
      stars: 1,
    );

    expect(CampaignProgress.starsFor('1-1'), 3);
  });

  test('a loss (0 stars) does not unlock the next level', () async {
    await CampaignProgress.recordResult(
      levelId: '1-1',
      overallIndex: 0,
      stars: 0,
    );

    expect(CampaignProgress.unlockedCount, 1);
    expect(CampaignProgress.isUnlocked(1), isFalse);
  });
}
