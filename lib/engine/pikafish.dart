import 'dart:math';

import '../game/board.dart';

/// Stub Pikafish wrapper. Phase 2 replaces this with the real WASM/native
/// UCI engine; for now it picks a uniformly random legal move so the rest
/// of the app can be wired against a stable API ahead of time.
class Pikafish {
  final Random _random;

  Pikafish({Random? random}) : _random = random ?? Random();

  Future<BoardMove?> getBestMove(Board board, {int movetimeMs = 100}) async {
    await Future<void>.delayed(Duration(milliseconds: movetimeMs));
    final moves = board.allLegalMoves(board.turn);
    if (moves.isEmpty) return null;
    return moves[_random.nextInt(moves.length)];
  }
}
