import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Vertical evaluation bar showing the engine's material balance
/// (-1 = Black favored, +1 = Red favored).
class EvalBar extends StatelessWidget {
  final double value;
  final Palette palette;

  const EvalBar({super.key, required this.palette, this.value = 0});

  @override
  Widget build(BuildContext context) {
    final redFraction = ((value + 1) / 2).clamp(0.0, 1.0);
    return Container(
      width: 6,
      height: 24,
      decoration: BoxDecoration(
        color: palette.blackPieceGradientEnd,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.bottomCenter,
        heightFactor: redFraction,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.gridLines,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
