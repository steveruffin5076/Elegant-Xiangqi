import 'package:flutter_test/flutter_test.dart';

import 'package:elegant_xiangqi/game/board.dart';
import 'package:elegant_xiangqi/game/campaign_data.dart';
import 'package:elegant_xiangqi/game/piece.dart';

void main() {
  test('there are exactly 50 levels across 5 chapters', () {
    expect(campaignChapters, hasLength(5));
    expect(allCampaignLevels, hasLength(50));
    expect(
      campaignChapters.map((c) => c.levels.length).toList(),
      [10, 10, 15, 10, 5],
    );
  });

  test('level ids are unique and overall indices are 0..49 in order', () {
    final ids = allCampaignLevels.map((l) => l.id).toSet();
    expect(ids, hasLength(50));
    expect(
      allCampaignLevels.map((l) => l.overallIndex).toList(),
      List.generate(50, (i) => i),
    );
  });

  test('every level FEN parses to a playable, Red-to-move position', () {
    for (final level in allCampaignLevels) {
      final board = Board.fromFen(level.fen);
      expect(
        board.turn,
        Side.red,
        reason: '${level.id} should start with Red to move',
      );
      expect(
        board.findGeneral(Side.red),
        isNotNull,
        reason: '${level.id} is missing a Red general',
      );
      expect(
        board.findGeneral(Side.black),
        isNotNull,
        reason: '${level.id} is missing a Black general',
      );
      expect(
        board.isGameOver,
        isFalse,
        reason: '${level.id} should not start already over',
      );
    }
  });

  test('opponent difficulty is non-decreasing across the campaign', () {
    for (var i = 1; i < allCampaignLevels.length; i++) {
      expect(
        allCampaignLevels[i].opponentDifficulty.level,
        greaterThanOrEqualTo(allCampaignLevels[i - 1].opponentDifficulty.level),
        reason:
            'Level ${allCampaignLevels[i].id} should not be easier than '
            '${allCampaignLevels[i - 1].id}',
      );
    }
  });
}
