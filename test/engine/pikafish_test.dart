import 'package:flutter_test/flutter_test.dart';

import 'package:elegant_xiangqi/engine/pikafish.dart';
import 'package:elegant_xiangqi/game/board.dart';
import 'package:elegant_xiangqi/game/difficulty.dart';

const _fastNoBlunder = Difficulty(
  level: 0,
  title: 'test',
  movetimeMs: 1,
  searchDepth: 3,
  blunderChance: 0.0,
);

void main() {
  group('Difficulty table', () {
    test('has 8 levels with increasing movetime', () {
      expect(difficulties, hasLength(8));
      for (var i = 1; i < difficulties.length; i++) {
        expect(
          difficulties[i].movetimeMs,
          greaterThan(difficulties[i - 1].movetimeMs),
        );
      }
    });

    test('levels are numbered 1 through 8', () {
      expect(
        difficulties.map((d) => d.level).toList(),
        [1, 2, 3, 4, 5, 6, 7, 8],
      );
    });
  });

  group('Pikafish (heuristic engine)', () {
    test('returns null when there are no legal moves', () async {
      final engine = Pikafish();
      // Same two-chariot corner mate verified in rules_test.dart: Black
      // to move, checkmated, zero legal moves.
      final board = Board.fromFen('3k5/9/3RR4/9/9/9/9/9/9/4K4 b - - 0 1');
      expect(board.isGameOver, isTrue);
      final move = await engine.getBestMove(board, _fastNoBlunder);
      expect(move, isNull);
    });

    test('prefers capturing a free chariot over a quiet move', () async {
      final engine = Pikafish();
      // Red chariot can capture Black's undefended chariot in one move.
      final board = Board.fromFen('9/9/9/4r4/9/9/9/9/9/4R4 w - - 0 1');
      final move = await engine.getBestMove(board, _fastNoBlunder);
      expect(move, isNotNull);
      expect(move!.to, const BoardPosition(3, 4));
    });

    test(
      'avoids a capture that loses material to a defended recapture',
      () async {
        final engine = Pikafish();
        // Red horse can grab a black soldier at (4,4), but Black's chariot
        // sits on the same file and recaptures for a net loss (soldier +1
        // vs. horse -4). A single-ply material eval would blunder into
        // this; depth-2+ lookahead (seeing Black's reply) should not.
        final board = Board.fromFen(
          '4r4/3k5/9/9/4p4/9/3N5/9/4K4/9 w - - 0 1',
        );
        const lookahead = Difficulty(
          level: 0,
          title: 'test',
          movetimeMs: 50,
          searchDepth: 3,
          blunderChance: 0.0,
        );
        final move = await engine.getBestMove(board, lookahead);
        expect(move, isNotNull);
        expect(move!.to, isNot(const BoardPosition(4, 4)));
      },
    );

    test('completes quickly even at the deepest search level', () async {
      final engine = Pikafish();
      final board = Board.initial();
      final stopwatch = Stopwatch()..start();
      final move = await engine.getBestMove(board, _fastNoBlunder);
      stopwatch.stop();
      expect(move, isNotNull);
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
    });

    test('evaluateMaterialForRed is zero on the symmetric starting position', () {
      final engine = Pikafish();
      expect(engine.evaluateMaterialForRed(Board.initial()), 0);
    });

    test('evaluateMaterialForRed favors the side with extra material', () {
      final engine = Pikafish();
      final board = Board.fromFen('9/9/9/9/9/9/9/9/9/3RK4 w - - 0 1');
      expect(engine.evaluateMaterialForRed(board), greaterThan(0));
    });
  });
}
