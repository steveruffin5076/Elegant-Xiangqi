import 'piece.dart';
import 'rules.dart';

class BoardPosition {
  final int row;
  final int col;

  const BoardPosition(this.row, this.col);

  bool get isValid =>
      row >= 0 && row < Board.rows && col >= 0 && col < Board.cols;

  @override
  bool operator ==(Object other) =>
      other is BoardPosition && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}

class BoardMove {
  final BoardPosition from;
  final BoardPosition to;

  const BoardMove(this.from, this.to);

  @override
  bool operator ==(Object other) =>
      other is BoardMove && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// Standard Xiangqi starting position. 'w' moves first (Red).
const startingFen =
    'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1';

class Board {
  static const int rows = 10;
  static const int cols = 9;

  final List<List<Piece?>> squares;
  final Side turn;

  Board({required this.squares, required this.turn});

  factory Board.initial() => Board.fromFen(startingFen);

  factory Board.fromFen(String fen) {
    final parts = fen.trim().split(RegExp(r'\s+'));
    final rowsPart = parts[0].split('/');
    if (rowsPart.length != rows) {
      throw ArgumentError(
        'FEN must describe $rows rows, got ${rowsPart.length}',
      );
    }
    final grid = List.generate(rows, (_) => List<Piece?>.filled(cols, null));
    for (var r = 0; r < rows; r++) {
      var c = 0;
      for (final ch in rowsPart[r].split('')) {
        final digit = int.tryParse(ch);
        if (digit != null) {
          c += digit;
        } else {
          grid[r][c] = Piece.fromFenChar(ch);
          c += 1;
        }
      }
      if (c != cols) {
        throw ArgumentError('FEN row $r does not span $cols columns');
      }
    }
    final turn = (parts.length > 1 && parts[1] == 'b') ? Side.black : Side.red;
    return Board(squares: grid, turn: turn);
  }

  String toFen() {
    final rowStrings = <String>[];
    for (var r = 0; r < rows; r++) {
      final buffer = StringBuffer();
      var empty = 0;
      for (var c = 0; c < cols; c++) {
        final piece = squares[r][c];
        if (piece == null) {
          empty++;
        } else {
          if (empty > 0) {
            buffer.write(empty);
            empty = 0;
          }
          buffer.write(piece.fenChar);
        }
      }
      if (empty > 0) buffer.write(empty);
      rowStrings.add(buffer.toString());
    }
    final turnChar = turn == Side.red ? 'w' : 'b';
    return '${rowStrings.join('/')} $turnChar - - 0 1';
  }

  Piece? pieceAt(BoardPosition pos) =>
      pos.isValid ? squares[pos.row][pos.col] : null;

  BoardPosition? findGeneral(Side side) {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final piece = squares[r][c];
        if (piece != null &&
            piece.type == PieceType.general &&
            piece.side == side) {
          return BoardPosition(r, c);
        }
      }
    }
    return null;
  }

  Board applyMove(BoardMove move) {
    final newGrid = [
      for (final row in squares) List<Piece?>.from(row),
    ];
    final moving = newGrid[move.from.row][move.from.col];
    newGrid[move.from.row][move.from.col] = null;
    newGrid[move.to.row][move.to.col] = moving;
    return Board(squares: newGrid, turn: turn.opponent);
  }

  /// Pseudo-legal moves for the piece at [from], ignoring whether the move
  /// would leave the moving side's own general in check.
  List<BoardMove> pseudoLegalMoves(BoardPosition from) =>
      Rules.pseudoLegalMoves(this, from);

  bool isInCheck(Side side) {
    if (Rules.generalsFaceOff(this)) return true;
    final generalPos = findGeneral(side);
    if (generalPos == null) return false;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final piece = squares[r][c];
        if (piece == null || piece.side == side) continue;
        final attacks = Rules.pseudoLegalMoves(this, BoardPosition(r, c));
        if (attacks.any((m) => m.to == generalPos)) return true;
      }
    }
    return false;
  }

  /// Legal moves for the piece at [from]: pseudo-legal moves that do not
  /// leave the moving side's own general in check (including the "flying
  /// general" position where both generals face each other on an open file).
  List<BoardMove> legalMoves(BoardPosition from) {
    final piece = pieceAt(from);
    if (piece == null) return const [];
    return pseudoLegalMoves(
      from,
    ).where((m) => !applyMove(m).isInCheck(piece.side)).toList();
  }

  List<BoardMove> allLegalMoves(Side side) {
    final moves = <BoardMove>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final piece = squares[r][c];
        if (piece != null && piece.side == side) {
          moves.addAll(legalMoves(BoardPosition(r, c)));
        }
      }
    }
    return moves;
  }

  bool get isCheckmate => isInCheck(turn) && allLegalMoves(turn).isEmpty;

  bool get isStalemate => !isInCheck(turn) && allLegalMoves(turn).isEmpty;
}
