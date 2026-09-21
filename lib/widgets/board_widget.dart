import 'package:flutter/material.dart';

import '../game/board.dart';
import '../theme/colors.dart';
import 'piece_widget.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final BoardPosition? selected;
  final List<BoardPosition> legalDestinations;
  final ValueChanged<BoardPosition> onTapSquare;

  const BoardWidget({
    super.key,
    required this.board,
    required this.selected,
    required this.legalDestinations,
    required this.onTapSquare,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: Board.cols / Board.rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final cellWidth = width / Board.cols;
          final cellHeight = height / Board.rows;

          void handleTap(TapUpDetails details) {
            final col = (details.localPosition.dx / cellWidth)
                .floor()
                .clamp(0, Board.cols - 1);
            final row = (details.localPosition.dy / cellHeight)
                .floor()
                .clamp(0, Board.rows - 1);
            onTapSquare(BoardPosition(row, col));
          }

          return GestureDetector(
            onTapUp: handleTap,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(width, height),
                  painter: _BoardPainter(
                    selected: selected,
                    legalDestinations: legalDestinations,
                  ),
                ),
                for (var r = 0; r < Board.rows; r++)
                  for (var c = 0; c < Board.cols; c++)
                    if (board.squares[r][c] != null)
                      Positioned(
                        left: c * cellWidth + cellWidth * 0.05,
                        top: r * cellHeight + cellHeight * 0.05,
                        width: cellWidth * 0.9,
                        height: cellHeight * 0.9,
                        child: PieceWidget(
                          piece: board.squares[r][c]!,
                          selected: selected == BoardPosition(r, c),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final BoardPosition? selected;
  final List<BoardPosition> legalDestinations;

  _BoardPainter({required this.selected, required this.legalDestinations});

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / Board.cols;
    final cellHeight = size.height / Board.rows;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.huanghuali,
    );

    final linePaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var c = 0; c < Board.cols; c++) {
      final x = c * cellWidth + cellWidth / 2;
      canvas.drawLine(
        Offset(x, cellHeight / 2),
        Offset(x, size.height - cellHeight / 2),
        linePaint,
      );
    }
    for (var r = 0; r < Board.rows; r++) {
      final y = r * cellHeight + cellHeight / 2;
      canvas.drawLine(
        Offset(cellWidth / 2, y),
        Offset(size.width - cellWidth / 2, y),
        linePaint,
      );
    }

    // River band between rows 4 and 5, inscribed with 楚河 汉界.
    final riverTop = 4 * cellHeight + cellHeight / 2;
    canvas.drawRect(
      Rect.fromLTWH(0, riverTop, size.width, cellHeight),
      Paint()..color = AppColors.jadeWhite.withValues(alpha: 0.5),
    );
    final riverText = TextPainter(
      text: const TextSpan(
        text: '楚 河          汉 界',
        style: TextStyle(
          color: AppColors.gold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    riverText.paint(
      canvas,
      Offset(
        (size.width - riverText.width) / 2,
        riverTop + (cellHeight - riverText.height) / 2,
      ),
    );

    _drawPalace(canvas, cellWidth, cellHeight, topRow: 0);
    _drawPalace(canvas, cellWidth, cellHeight, topRow: 7);

    if (selected != null) {
      final center = Offset(
        selected!.col * cellWidth + cellWidth / 2,
        selected!.row * cellHeight + cellHeight / 2,
      );
      canvas.drawCircle(
        center,
        cellWidth * 0.42,
        Paint()
          ..color = AppColors.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
    for (final dest in legalDestinations) {
      final center = Offset(
        dest.col * cellWidth + cellWidth / 2,
        dest.row * cellHeight + cellHeight / 2,
      );
      canvas.drawCircle(
        center,
        cellWidth * 0.12,
        Paint()..color = AppColors.obsidianBlack.withValues(alpha: 0.4),
      );
    }
  }

  void _drawPalace(
    Canvas canvas,
    double cellWidth,
    double cellHeight, {
    required int topRow,
  }) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final left = 3 * cellWidth + cellWidth / 2;
    final right = 5 * cellWidth + cellWidth / 2;
    final top = topRow * cellHeight + cellHeight / 2;
    final bottom = (topRow + 2) * cellHeight + cellHeight / 2;
    canvas.drawLine(Offset(left, top), Offset(right, bottom), paint);
    canvas.drawLine(Offset(right, top), Offset(left, bottom), paint);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) =>
      oldDelegate.selected != selected ||
      oldDelegate.legalDestinations != legalDestinations;
}
