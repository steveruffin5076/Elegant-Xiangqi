import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elegant_xiangqi/theme/palette.dart';
import 'package:elegant_xiangqi/widgets/game_result_dialog.dart';

void main() {
  testWidgets('shows the message and fires onClose / onRetry', (
    WidgetTester tester,
  ) async {
    var closed = false;
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => GameResultDialog(
                  message: '红方胜！',
                  palette: huanghualiJade,
                  onClose: () {
                    closed = true;
                    Navigator.of(context).pop();
                  },
                  onRetry: () {
                    retried = true;
                    Navigator.of(context).pop();
                  },
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('红方胜！'), findsOneWidget);
    expect(find.byType(GameResultDialog), findsOneWidget);

    await tester.tap(find.text('再来一局 Retry'));
    await tester.pumpAndSettle();

    expect(retried, isTrue);
    expect(find.byType(GameResultDialog), findsNothing);
    expect(closed, isFalse);
  });
}
