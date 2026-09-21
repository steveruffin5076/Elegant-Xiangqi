import 'dart:math';

import '../game/board.dart';
import '../game/difficulty.dart';
import '../game/piece.dart';

/// Stand-in for the real Pikafish WASM/native engine (see MUSE.md — this
/// file is the intended home for that wrapper). Until that lands, this is
/// a local alpha-beta search over material value, deliberately shallow
/// (Board.legalMoves does a full check-simulation per candidate, so an
/// unbounded search here would be too slow to stay responsive on a phone).
/// [Difficulty] tunes both the depth ceiling and a "blunder" chance —
/// weaker levels sometimes play a lower-ranked move on purpose, per the
/// design doc's "don't just reduce time" guidance — rather than only
/// getting faster/slower.
class Pikafish {
  final Random _random;

  Pikafish({Random? random}) : _random = random ?? Random();

  static const _hardDepthCap = 4;

  Future<BoardMove?> getBestMove(Board board, Difficulty difficulty) async {
    final deadline = DateTime.now().add(
      Duration(milliseconds: difficulty.movetimeMs),
    );

    var ranked = board.allLegalMoves(board.turn);
    if (ranked.isEmpty) return null;

    final maxDepth = difficulty.searchDepth.clamp(1, _hardDepthCap);
    for (var depth = 1; depth <= maxDepth; depth++) {
      ranked = _rankMoves(board, depth);
      if (DateTime.now().isAfter(deadline)) break;
    }

    final move = _pickWithBlunder(ranked, difficulty.blunderChance);

    final remaining = deadline.difference(DateTime.now());
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    return move;
  }

  /// Legal moves for [board]'s side to move, best-first by [depth]-ply
  /// negamax search.
  List<BoardMove> _rankMoves(Board board, int depth) {
    final moves = board.allLegalMoves(board.turn);
    final scored = <MapEntry<BoardMove, double>>[
      for (final move in moves)
        MapEntry(
          move,
          -_search(board.applyMove(move), depth - 1, -_infinity, _infinity),
        ),
    ];
    scored.sort((a, b) => b.value.compareTo(a.value));
    return [for (final entry in scored) entry.key];
  }

  static const _infinity = 1e9;

  double _search(Board board, int depth, double alpha, double beta) {
    final moves = board.allLegalMoves(board.turn);
    if (moves.isEmpty) {
      // Xiangqi has no stalemate draw: no legal moves is a loss for the
      // side to move. Prefer a faster loss/slower win by weighting depth.
      return -_infinity + (_hardDepthCap - depth);
    }
    if (depth <= 0) {
      return _evaluate(board, board.turn);
    }
    _orderByCaptures(board, moves);
    var best = -_infinity;
    for (final move in moves) {
      final score = -_search(board.applyMove(move), depth - 1, -beta, -alpha);
      if (score > best) best = score;
      if (best > alpha) alpha = best;
      if (alpha >= beta) break; // alpha-beta cutoff
    }
    return best;
  }

  void _orderByCaptures(Board board, List<BoardMove> moves) {
    moves.sort((a, b) {
      final aCapture = board.pieceAt(a.to) != null ? 1 : 0;
      final bCapture = board.pieceAt(b.to) != null ? 1 : 0;
      return bCapture.compareTo(aCapture);
    });
  }

  BoardMove _pickWithBlunder(
    List<BoardMove> rankedBestFirst,
    double blunderChance,
  ) {
    if (rankedBestFirst.length == 1 || blunderChance <= 0) {
      return rankedBestFirst.first;
    }
    if (_random.nextDouble() < blunderChance) {
      final poolSize = min(3, rankedBestFirst.length);
      return rankedBestFirst[_random.nextInt(poolSize)];
    }
    return rankedBestFirst.first;
  }

  static const _pieceValues = {
    PieceType.general: 0.0,
    PieceType.advisor: 2.0,
    PieceType.elephant: 2.0,
    PieceType.horse: 4.0,
    PieceType.cannon: 4.5,
    PieceType.chariot: 9.0,
    PieceType.soldier: 1.0,
  };

  double _evaluate(Board board, Side perspective) {
    final redMaterial = evaluateMaterialForRed(board);
    return perspective == Side.red ? redMaterial : -redMaterial;
  }

  /// Raw material balance from Red's perspective (positive favors Red) —
  /// exposed for the UI's evaluation bar, using the same values the search
  /// scores positions with.
  double evaluateMaterialForRed(Board board) {
    var score = 0.0;
    for (final row in board.squares) {
      for (final piece in row) {
        if (piece == null) continue;
        final value = _pieceValues[piece.type]!;
        score += piece.side == Side.red ? value : -value;
      }
    }
    return score;
  }
}
