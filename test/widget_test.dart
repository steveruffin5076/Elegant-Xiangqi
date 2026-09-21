import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elegant_xiangqi/main.dart';

void main() {
  testWidgets('renders the portrait game screen with a board', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElegantXiangqiApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('红方走棋'), findsOneWidget);
  });
}
