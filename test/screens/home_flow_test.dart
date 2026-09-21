import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elegant_xiangqi/game/board.dart';
import 'package:elegant_xiangqi/game/difficulty.dart';
import 'package:elegant_xiangqi/main.dart';
import 'package:elegant_xiangqi/screens/difficulty_select_screen.dart';
import 'package:elegant_xiangqi/screens/game_screen.dart';
import 'package:elegant_xiangqi/screens/home_screen.dart';
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
  testWidgets('menu -> vs AI -> difficulty select -> starts an AI game', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElegantXiangqiApp());
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.textContaining('人机对战'));
    await tester.pumpAndSettle();
    expect(find.byType(DifficultySelectScreen), findsOneWidget);

    await tester.tap(find.text('童生 Tongsheng'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
  });

  testWidgets('the AI replies after the human moves', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: GameScreen(aiDifficulty: difficulties.first)),
    );
    await tester.pumpAndSettle();

    expect(find.text('红方走棋'), findsOneWidget);

    // Human (Red) plays a soldier forward; AI (Black) should reply.
    await tester.tapAt(_cellCenter(tester, const BoardPosition(6, 4)));
    await tester.pumpAndSettle();
    await tester.tapAt(_cellCenter(tester, const BoardPosition(5, 4)));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('红方走棋'), findsOneWidget);
  });
}
