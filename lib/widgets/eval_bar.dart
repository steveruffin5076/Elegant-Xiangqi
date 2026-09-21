import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Vertical evaluation bar. Neutral placeholder until Phase 2 wires it to
/// the engine's evaluation score (-10 to +10, Red-positive).
class EvalBar extends StatelessWidget {
  final double value;

  const EvalBar({super.key, this.value = 0});

  @override
  Widget build(BuildContext context) {
    final redFraction = ((value + 1) / 2).clamp(0.0, 1.0);
    return Container(
      width: 6,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.obsidianBlack,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.bottomCenter,
        heightFactor: redFraction,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
