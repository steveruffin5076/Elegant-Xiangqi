import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elegant_xiangqi/main.dart';

void main() {
  testWidgets('launches to the main menu, and vs-human starts a game', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElegantXiangqiApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('象棋'), findsOneWidget);

    await tester.tap(find.textContaining('双人对战'));
    await tester.pumpAndSettle();

    expect(find.text('红方走棋'), findsOneWidget);
  });
}
