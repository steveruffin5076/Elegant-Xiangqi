import 'package:hive/hive.dart';

/// Persists campaign completion via Hive, per the plan's `campaign_progress`
/// box (chapter/level/stars). Progression is a single linear "unlocked
/// count" across all 50 levels rather than per-chapter tracking — simpler,
/// and matches how `campaign_map_screen.dart` presents one continuous
/// scroll rather than separate chapter gates.
///
/// Call [init] once (after `Hive.initFlutter()` in the real app, or
/// `Hive.init(tempDir)` in tests) before reading or writing progress.
class CampaignProgress {
  CampaignProgress._();

  static const boxName = 'campaign_progress';
  static const _starsKey = 'stars';
  static const _unlockedKey = 'unlockedCount';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<dynamic>(boxName);
    }
  }

  static Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  /// Best stars (0-3) earned for [levelId], or 0 if never completed.
  static int starsFor(String levelId) {
    final stars = _box.get(_starsKey) as Map?;
    return (stars?[levelId] as int?) ?? 0;
  }

  /// How many levels (by overall index, 0-based) are unlocked. Level 0
  /// (the very first) is always unlocked.
  static int get unlockedCount => (_box.get(_unlockedKey) as int?) ?? 1;

  static bool isUnlocked(int overallIndex) => overallIndex < unlockedCount;

  /// Records the outcome of playing [levelId] (at [overallIndex] in the
  /// full sequence): keeps the best star count, and on any win unlocks
  /// the next level.
  static Future<void> recordResult({
    required String levelId,
    required int overallIndex,
    required int stars,
  }) async {
    final starsMap = Map<String, dynamic>.from(
      (_box.get(_starsKey) as Map?) ?? {},
    );
    final existing = starsMap[levelId] as int? ?? 0;
    if (stars > existing) {
      starsMap[levelId] = stars;
      await _box.put(_starsKey, starsMap);
    }
    // isUnlocked(i) checks i < unlockedCount, so unlocking the NEXT level
    // (overallIndex + 1) requires unlockedCount to reach overallIndex + 2.
    final newUnlockedCount = overallIndex + 2;
    if (stars > 0 && newUnlockedCount > unlockedCount) {
      await _box.put(_unlockedKey, newUnlockedCount);
    }
  }
}
