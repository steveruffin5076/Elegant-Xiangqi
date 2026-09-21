import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Ink-diffusion particle burst played when a piece is captured: ~10 black
/// dots spreading outward and fading, per the Phase 1 art spec.
class CaptureInkSplash extends StatefulWidget {
  final VoidCallback onCompleted;

  const CaptureInkSplash({super.key, required this.onCompleted});

  @override
  State<CaptureInkSplash> createState() => _CaptureInkSplashState();
}

class _CaptureInkSplashState extends State<CaptureInkSplash>
    with SingleTickerProviderStateMixin {
  static const _dotCount = 10;

  late final AnimationController _controller;
  late final List<Offset> _directions;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _directions = List.generate(_dotCount, (_) {
      final angle = random.nextDouble() * 2 * pi;
      return Offset(cos(angle), sin(angle));
    });
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 420),
        )
        ..forward()
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onCompleted();
        });
  }

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
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _InkSplashPainter(
            progress: _controller.value,
            directions: _directions,
          ),
        ),
      ),
    );
  }
}

class _InkSplashPainter extends CustomPainter {
  final double progress;
  final List<Offset> directions;

  _InkSplashPainter({required this.progress, required this.directions});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide * 0.6;
    final paint = Paint()
      ..color = AppColors.obsidianBlack.withValues(
        alpha: (1 - progress).clamp(0.0, 1.0),
      );
    for (final direction in directions) {
      final dot = center + direction * (maxRadius * progress);
      final radius = 3.0 * (1 - progress) + 1.0;
      canvas.drawCircle(dot, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _InkSplashPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
