import 'board.dart';
import 'piece.dart';

/// Xiangqi movement rules: Horse leg block, Elephant eye, Cannon jump,
/// Palace confinement, River crossing, and the Flying General restriction.
class Rules {
  Rules._();

  static const orthogonalDirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];
  static const diagonalDirs = [(-1, -1), (-1, 1), (1, -1), (1, 1)];

  static bool inPalace(Side side, int row, int col) {
    if (col < 3 || col > 5) return false;
    return side == Side.black
        ? (row >= 0 && row <= 2)
        : (row >= 7 && row <= 9);
  }

  static bool inOwnHalf(Side side, int row) =>
      side == Side.black ? row <= 4 : row >= 5;

  static bool canLandOn(Board board, BoardPosition pos, Side side) {
    if (!pos.isValid) return false;
    final occupant = board.pieceAt(pos);
    return occupant == null || occupant.side != side;
  }

  static List<BoardMove> generalMoves(
    Board board,
    BoardPosition from,
    Side side,
  ) {
    final moves = <BoardMove>[];
    for (final d in orthogonalDirs) {
      final to = BoardPosition(from.row + d.$1, from.col + d.$2);
      if (to.isValid &&
          inPalace(side, to.row, to.col) &&
          canLandOn(board, to, side)) {
        moves.add(BoardMove(from, to));
      }
    }
    return moves;
  }

  static List<BoardMove> advisorMoves(
    Board board,
    BoardPosition from,
    Side side,
  ) {
    final moves = <BoardMove>[];
    for (final d in diagonalDirs) {
      final to = BoardPosition(from.row + d.$1, from.col + d.$2);
      if (to.isValid &&
          inPalace(side, to.row, to.col) &&
          canLandOn(board, to, side)) {
        moves.add(BoardMove(from, to));
      }
    }
    return moves;
  }

  static List<BoardMove> elephantMoves(
    Board board,
    BoardPosition from,
    Side side,
  ) {
    final moves = <BoardMove>[];
    for (final d in diagonalDirs) {
      final eye = BoardPosition(from.row + d.$1, from.col + d.$2);
      final to = BoardPosition(from.row + 2 * d.$1, from.col + 2 * d.$2);
      if (!to.isValid || !inOwnHalf(side, to.row)) continue;
      if (board.pieceAt(eye) != null) continue; // blocked eye
      if (canLandOn(board, to, side)) moves.add(BoardMove(from, to));
    }
    return moves;
  }

  // (dRow, dCol, legRow, legCol) — the leg is the orthogonal square in the
  // direction of the horse's first step; a piece there hobbles the move.
  static const _horseSteps = [
    (-2, -1, -1, 0),
    (-2, 1, -1, 0),
    (2, -1, 1, 0),
    (2, 1, 1, 0),
    (-1, -2, 0, -1),
    (1, -2, 0, -1),
    (-1, 2, 0, 1),
    (1, 2, 0, 1),
  ];

  static List<BoardMove> horseMoves(
    Board board,
    BoardPosition from,
    Side side,
  ) {
    final moves = <BoardMove>[];
    for (final step in _horseSteps) {
      final leg = BoardPosition(from.row + step.$3, from.col + step.$4);
      if (board.pieceAt(leg) != null) continue; // hobbled leg
      final to = BoardPosition(from.row + step.$1, from.col + step.$2);
      if (to.isValid && canLandOn(board, to, side)) {
        moves.add(BoardMove(from, to));
      }
    }
    return moves;
  }

  static List<BoardMove> chariotMoves(
    Board board,
    BoardPosition from,
    Side side,
  ) {
    final moves = <BoardMove>[];
    for (final d in orthogonalDirs) {
      var to = BoardPosition(from.row + d.$1, from.col + d.$2);
      while (to.isValid) {
        final occupant = board.pieceAt(to);
        if (occupant == null) {
          moves.add(BoardMove(from, to));
        } else {
          if (occupant.side != side) moves.add(BoardMove(from, to));
          break;
        }
        to = BoardPosition(to.row + d.$1, to.col + d.$2);
      }
    }
    return moves;
  }

  static List<BoardMove> cannonMoves(
    Board board,
    BoardPosition from,
    Side side,
  ) {
    final moves = <BoardMove>[];
    for (final d in orthogonalDirs) {
      var pos = BoardPosition(from.row + d.$1, from.col + d.$2);
      var screenFound = false;
      while (pos.isValid) {
        final occupant = board.pieceAt(pos);
        if (!screenFound) {
          if (occupant == null) {
            moves.add(BoardMove(from, pos));
          } else {
            screenFound = true;
          }
        } else if (occupant != null) {
          if (occupant.side != side) moves.add(BoardMove(from, pos));
          break;
        }
        pos = BoardPosition(pos.row + d.$1, pos.col + d.$2);
      }
    }
    return moves;
  }

  static List<BoardMove> soldierMoves(
    Board board,
    BoardPosition from,
    Side side,
  ) {
    final moves = <BoardMove>[];
    final forward = side == Side.black ? 1 : -1;
    final ahead = BoardPosition(from.row + forward, from.col);
    if (ahead.isValid && canLandOn(board, ahead, side)) {
      moves.add(BoardMove(from, ahead));
    }
    if (!inOwnHalf(side, from.row)) {
      for (final dc in [-1, 1]) {
        final sideways = BoardPosition(from.row, from.col + dc);
        if (sideways.isValid && canLandOn(board, sideways, side)) {
          moves.add(BoardMove(from, sideways));
        }
      }
    }
    return moves;
  }

  static List<BoardMove> pseudoLegalMoves(Board board, BoardPosition from) {
    final piece = board.pieceAt(from);
    if (piece == null) return const [];
    switch (piece.type) {
      case PieceType.general:
        return generalMoves(board, from, piece.side);
      case PieceType.advisor:
        return advisorMoves(board, from, piece.side);
      case PieceType.elephant:
        return elephantMoves(board, from, piece.side);
      case PieceType.horse:
        return horseMoves(board, from, piece.side);
      case PieceType.chariot:
        return chariotMoves(board, from, piece.side);
      case PieceType.cannon:
        return cannonMoves(board, from, piece.side);
      case PieceType.soldier:
        return soldierMoves(board, from, piece.side);
    }
  }

  /// True if both generals stand on the same file with nothing between them
  /// — an illegal "flying general" position, treated as check for both sides.
  static bool generalsFaceOff(Board board) {
    final red = board.findGeneral(Side.red);
    final black = board.findGeneral(Side.black);
    if (red == null || black == null || red.col != black.col) return false;
    final lo = (red.row < black.row ? red.row : black.row) + 1;
    final hi = red.row < black.row ? black.row : red.row;
    for (var r = lo; r < hi; r++) {
      if (board.pieceAt(BoardPosition(r, red.col)) != null) return false;
    }
    return true;
  }
}
