import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/board.dart';
import '../theme/colors.dart';
import 'ink_splash.dart';
import 'piece_widget.dart';
import 'pulsing_dot.dart';
import 'visual_piece.dart';

class BoardWidget extends StatelessWidget {
  final List<VisualPiece> pieces;
  final BoardPosition? selected;
  final List<BoardPosition> legalDestinations;
  final List<BoardPosition> blockedLegs;
  final int? shakingPieceId;
  final int shakeSeed;
  final Map<int, BoardPosition> activeSplashes;
  final ValueChanged<int> onSplashComplete;
  final ValueChanged<BoardPosition> onTapSquare;
  final BoardPosition? hintFrom;
  final BoardPosition? hintTo;

  const BoardWidget({
    super.key,
    required this.pieces,
    required this.selected,
    required this.legalDestinations,
    required this.blockedLegs,
    required this.shakingPieceId,
    required this.shakeSeed,
    required this.activeSplashes,
    required this.onSplashComplete,
    required this.onTapSquare,
    this.hintFrom,
    this.hintTo,
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
                    blockedLegs: blockedLegs,
                  ),
                ),
                for (final visualPiece in pieces)
                  AnimatedPositioned(
                    key: ValueKey(visualPiece.id),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: visualPiece.position.col * cellWidth + cellWidth * 0.05,
                    top: visualPiece.position.row * cellHeight + cellHeight * 0.05,
                    width: cellWidth * 0.9,
                    height: cellHeight * 0.9,
                    child: PieceWidget(
                      piece: visualPiece.piece,
                      selected: selected == visualPiece.position,
                      shakeSeed: shakingPieceId == visualPiece.id
                          ? shakeSeed
                          : 0,
                    ),
                  ),
                for (final entry in activeSplashes.entries)
                  Positioned(
                    left: entry.value.col * cellWidth,
                    top: entry.value.row * cellHeight,
                    width: cellWidth,
                    height: cellHeight,
                    child: CaptureInkSplash(
                      onCompleted: () => onSplashComplete(entry.key),
                    ),
                  ),
                for (final hint in [hintFrom, hintTo])
                  if (hint != null)
                    Positioned(
                      key: ValueKey('hint-$hint'),
                      left: hint.col * cellWidth,
                      top: hint.row * cellHeight,
                      width: cellWidth,
                      height: cellHeight,
                      child: const PulsingDot(),
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
  final List<BoardPosition> blockedLegs;

  _BoardPainter({
    required this.selected,
    required this.legalDestinations,
    required this.blockedLegs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / Board.cols;
    final cellHeight = size.height / Board.rows;
    final rect = Offset.zero & size;

    // Huanghuali wood: warm gradient standing in for a scanned PBR texture.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C6A38), AppColors.huanghuali, Color(0xFF7A4B20)],
        ).createShader(rect),
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
    final riverRect = Rect.fromLTWH(0, riverTop, size.width, cellHeight);
    canvas.drawRect(
      riverRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.jadeWhite.withValues(alpha: 0.55),
            AppColors.celadon.withValues(alpha: 0.35),
            AppColors.jadeWhite.withValues(alpha: 0.55),
          ],
        ).createShader(riverRect),
    );
    final riverText = TextPainter(
      text: TextSpan(
        text: '楚 河          汉 界',
        style: GoogleFonts.notoSerifSc(
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

    for (final leg in blockedLegs) {
      _drawBlockedX(canvas, leg, cellWidth, cellHeight);
    }
  }

  void _drawPalace(
    Canvas canvas,
    double cellWidth,
    double cellHeight, {
    required int topRow,
  }) {
    final left = 3 * cellWidth + cellWidth / 2;
    final right = 5 * cellWidth + cellWidth / 2;
    final top = topRow * cellHeight + cellHeight / 2;
    final bottom = (topRow + 2) * cellHeight + cellHeight / 2;

    // Soft gold-leaf glow pass beneath the crisp diagonal lines.
    final glowPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.35)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(Offset(left, top), Offset(right, bottom), glowPaint);
    canvas.drawLine(Offset(right, top), Offset(left, bottom), glowPaint);

    final linePaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(left, top), Offset(right, bottom), linePaint);
    canvas.drawLine(Offset(right, top), Offset(left, bottom), linePaint);
  }

  void _drawBlockedX(
    Canvas canvas,
    BoardPosition pos,
    double cellWidth,
    double cellHeight,
  ) {
    final center = Offset(
      pos.col * cellWidth + cellWidth / 2,
      pos.row * cellHeight + cellHeight / 2,
    );
    final half = cellWidth * 0.2;
    final paint = Paint()
      ..color = AppColors.imperialRed
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center + Offset(-half, -half),
      center + Offset(half, half),
      paint,
    );
    canvas.drawLine(
      center + Offset(half, -half),
      center + Offset(-half, half),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) =>
      oldDelegate.selected != selected ||
      oldDelegate.legalDestinations != legalDestinations ||
      oldDelegate.blockedLegs != blockedLegs;
}
