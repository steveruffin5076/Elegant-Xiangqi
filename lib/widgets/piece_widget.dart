import 'package:flutter/material.dart';

import '../game/piece.dart';
import '../theme/colors.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final bool selected;

  const PieceWidget({super.key, required this.piece, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final isRed = piece.side == Side.red;
    final baseColor = isRed ? AppColors.jadeWhite : AppColors.obsidianBlack;
    final textColor = isRed ? AppColors.imperialRed : AppColors.jadeWhite;

    return AnimatedScale(
      scale: selected ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: baseColor,
          border: Border.all(color: AppColors.gold, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.6),
                    blurRadius: 12,
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
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
