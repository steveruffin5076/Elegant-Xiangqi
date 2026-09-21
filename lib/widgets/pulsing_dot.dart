import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// A continuously pulsing gold dot marking a hint's source/destination
/// square, per the plan's "pulsing gold dot" hint affordance.
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final scale = 0.6 + 0.4 * _controller.value;
          final opacity = 0.35 + 0.65 * _controller.value;
          return Center(
            child: FractionallySizedBox(
              widthFactor: 0.28,
              heightFactor: 0.28,
              child: Transform.scale(
                scale: scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: opacity),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
