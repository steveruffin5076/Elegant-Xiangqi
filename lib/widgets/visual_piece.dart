import '../game/board.dart';
import '../game/piece.dart';

/// A piece tracked by stable identity across moves, so the board can
/// animate it sliding from one square to another instead of popping it
/// into place. The [Board] (in `game/`) stays the source of truth for
/// rules; this is purely a rendering-layer concern.
class VisualPiece {
  final int id;
  final Piece piece;
  BoardPosition position;

  VisualPiece({required this.id, required this.piece, required this.position});
}
