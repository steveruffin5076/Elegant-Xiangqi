import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/piece.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final bool selected;
  final Palette palette;

  /// True while this piece is sliding to a new square — plays a "silk
  /// shadow" lift (a little bigger, shadow cast further down) so the move
  /// reads as picking the piece up and setting it back down, rather than
  /// it just gliding flat across the board.
  final bool lifted;

  /// Bumping this value plays a one-shot "invalid move" wiggle — used for
  /// a hobbled horse leg, an elephant blocked at the river, etc. A value
  /// of 0 means "not shaking".
  final int shakeSeed;

  const PieceWidget({
    super.key,
    required this.piece,
    required this.palette,
    this.selected = false,
    this.lifted = false,
    this.shakeSeed = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isRed = piece.side == Side.red;
    final textColor = isRed ? palette.redPieceText : palette.blackPieceText;

    final pieceBody = AnimatedScale(
      scale: selected
          ? 1.1
          : lifted
          ? 1.12
          : 1.0,
      duration: pieceMoveDuration,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: pieceMoveDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: isRed
                ? [palette.redPieceGradientStart, palette.redPieceGradientEnd]
                : [
                    palette.blackPieceGradientStart,
                    palette.blackPieceGradientEnd,
                  ],
          ),
          border: Border.all(color: palette.pieceRim, width: 2.5),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: palette.pieceRim.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ]
              : lifted
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              piece.character,
              style: GoogleFonts.notoSerifSc(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey(shakeSeed),
      tween: Tween(begin: 0, end: shakeSeed == 0 ? 0.0 : 1.0),
      duration: const Duration(milliseconds: 320),
      builder: (context, t, child) {
        final dx = sin(t * pi * 4) * 6 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: pieceBody,
    );
  }
}
