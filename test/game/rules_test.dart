import 'package:flutter_test/flutter_test.dart';

import 'package:elegant_xiangqi/game/board.dart';
import 'package:elegant_xiangqi/game/piece.dart';

void main() {
  group('FEN', () {
    test('initial board round-trips through FEN', () {
      final board = Board.initial();
      expect(board.toFen(), startingFen);
      expect(board.turn, Side.red);
    });

    test('parses a custom FEN and side to move', () {
      final board = Board.fromFen('9/9/9/9/9/9/9/9/9/4K4 b - - 0 1');
      expect(board.turn, Side.black);
      expect(
        board.pieceAt(const BoardPosition(9, 4)),
        const Piece(PieceType.general, Side.red),
      );
    });
  });

  group('Horse', () {
    test('is blocked by a piece directly on its leg', () {
      // Red horse at (9,1); a piece at (8,1) — one step "up" — is the leg
      // for both moves that jump over it.
      final board = Board.fromFen('9/9/9/9/9/9/9/9/1P7/1N7 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(9, 1))
          .map((m) => m.to)
          .toSet();
      expect(destinations, isNot(contains(const BoardPosition(7, 0))));
      expect(destinations, isNot(contains(const BoardPosition(7, 2))));
    });

    test('can jump when the leg is clear', () {
      final board = Board.fromFen('9/9/9/9/9/9/9/9/9/1N7 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(9, 1))
          .map((m) => m.to)
          .toSet();
      expect(destinations, contains(const BoardPosition(7, 0)));
      expect(destinations, contains(const BoardPosition(7, 2)));
      expect(destinations, contains(const BoardPosition(8, 3)));
    });
  });

  group('Elephant', () {
    test('is blocked by an occupied eye', () {
      // Red elephant at (9,2); its eye toward (7,0) is (8,1), occupied by
      // a friendly soldier.
      final board = Board.fromFen('9/9/9/9/9/9/9/9/1P7/2B6 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(9, 2))
          .map((m) => m.to)
          .toSet();
      expect(destinations, isNot(contains(const BoardPosition(7, 0))));
    });

    test('cannot cross the river', () {
      final board = Board.fromFen('9/9/9/9/9/9/2B6/9/9/9 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(6, 2))
          .map((m) => m.to)
          .toSet();
      expect(destinations, isNot(contains(const BoardPosition(4, 0))));
      expect(destinations, isNot(contains(const BoardPosition(4, 4))));
    });
  });

  group('Cannon', () {
    test('cannot capture without a screen', () {
      final board = Board.fromFen('9/9/9/9/4c4/9/9/9/9/4C4 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(9, 4))
          .map((m) => m.to)
          .toSet();
      expect(destinations, isNot(contains(const BoardPosition(4, 4))));
    });

    test('captures the piece beyond exactly one screen', () {
      final board = Board.fromFen('9/9/9/9/4c4/9/4P4/9/9/4C4 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(9, 4))
          .map((m) => m.to)
          .toSet();
      expect(destinations, contains(const BoardPosition(4, 4)));
    });

    test('slides freely along empty squares without capturing', () {
      final board = Board.fromFen('9/9/9/9/9/9/9/9/9/4C4 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(9, 4))
          .map((m) => m.to)
          .toSet();
      expect(destinations, contains(const BoardPosition(5, 4)));
    });
  });

  group('Soldier', () {
    test('cannot move sideways before crossing the river', () {
      final board = Board.fromFen('9/9/9/9/9/9/4P4/9/9/9 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(6, 4))
          .map((m) => m.to)
          .toSet();
      expect(destinations, isNot(contains(const BoardPosition(6, 3))));
      expect(destinations, contains(const BoardPosition(5, 4)));
    });

    test('can move sideways after crossing the river', () {
      final board = Board.fromFen('9/9/9/9/4P4/9/9/9/9/9 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(4, 4))
          .map((m) => m.to)
          .toSet();
      expect(destinations, contains(const BoardPosition(3, 4)));
      expect(destinations, contains(const BoardPosition(4, 3)));
      expect(destinations, contains(const BoardPosition(4, 5)));
      expect(destinations, isNot(contains(const BoardPosition(5, 4))));
    });
  });

  group('Check and Flying General', () {
    test('filters moves that expose the general to the opposing chariot', () {
      // Red general at (9,4); Red chariot at (8,4) blocks Black's chariot
      // at (0,4) from the file. Moving it off the file exposes check.
      final board = Board.fromFen('4r4/9/9/9/9/9/9/9/4R4/4K4 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(8, 4))
          .map((m) => m.to)
          .toSet();
      expect(destinations, isNot(contains(const BoardPosition(8, 3))));
      expect(destinations, contains(const BoardPosition(0, 4)));
    });

    test('kings facing off on an open file counts as check', () {
      final board = Board.fromFen('4k4/9/9/9/9/9/9/9/9/4K4 w - - 0 1');
      expect(board.isInCheck(Side.red), isTrue);
      expect(board.isInCheck(Side.black), isTrue);
    });

    test('a move that would face the generals off is illegal', () {
      final board = Board.fromFen('4k4/9/9/9/9/9/9/9/9/3K5 w - - 0 1');
      final destinations = board
          .legalMoves(const BoardPosition(9, 3))
          .map((m) => m.to)
          .toSet();
      expect(destinations, isNot(contains(const BoardPosition(9, 4))));
    });
  });

  group('Checkmate', () {
    test('two chariots mate a general cornered in the palace', () {
      // Black general boxed in palace corner (0,3): its only two moves,
      // (0,4) and (1,3), are both covered by the two Red chariots.
      final board = Board.fromFen('3k5/9/3RR4/9/9/9/9/9/9/4K4 b - - 0 1');
      expect(board.isInCheck(Side.black), isTrue);
      expect(board.allLegalMoves(Side.black), isEmpty);
      expect(board.isCheckmate, isTrue);
    });
  });
}
