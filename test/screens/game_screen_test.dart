import 'package:flutter_test/flutter_test.dart';

import 'package:elegant_xiangqi/game/board.dart';
import 'package:elegant_xiangqi/main.dart';
import 'package:elegant_xiangqi/widgets/board_widget.dart';

Offset _cellCenter(WidgetTester tester, BoardPosition pos) {
  final topLeft = tester.getTopLeft(find.byType(BoardWidget));
  final size = tester.getSize(find.byType(BoardWidget));
  final cellWidth = size.width / Board.cols;
  final cellHeight = size.height / Board.rows;
  return topLeft +
      Offset(
        pos.col * cellWidth + cellWidth / 2,
        pos.row * cellHeight + cellHeight / 2,
      );
}

void main() {
  testWidgets('tapping a piece then a legal square moves it and switches turn', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElegantXiangqiApp());
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('双人对战'));
    await tester.pumpAndSettle();

    expect(find.text('红方走棋'), findsOneWidget);

    // Red soldier at (6,4) steps forward to (5,4).
    await tester.tapAt(_cellCenter(tester, const BoardPosition(6, 4)));
    await tester.pumpAndSettle();
    await tester.tapAt(_cellCenter(tester, const BoardPosition(5, 4)));
    await tester.pumpAndSettle();

    expect(find.text('黑方走棋'), findsOneWidget);
  });

  testWidgets('tapping an illegal destination deselects without moving', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElegantXiangqiApp());
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('双人对战'));
    await tester.pumpAndSettle();

    // Select the red soldier, then tap a square it cannot reach.
    await tester.tapAt(_cellCenter(tester, const BoardPosition(6, 4)));
    await tester.pumpAndSettle();
    await tester.tapAt(_cellCenter(tester, const BoardPosition(3, 4)));
    await tester.pumpAndSettle();

    // Still Red's turn — the tap was rejected, not played as a move.
    expect(find.text('红方走棋'), findsOneWidget);
  });
}
