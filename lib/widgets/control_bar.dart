import 'package:flutter/material.dart';

import '../theme/colors.dart';

class ControlBar extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onHint;
  final VoidCallback? onMenu;
  final VoidCallback? onAnalysis;

  const ControlBar({
    super.key,
    this.onUndo,
    this.onHint,
    this.onMenu,
    this.onAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.celadon.withValues(alpha: 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(icon: Icons.undo, label: '悔棋', onPressed: onUndo),
          _ControlButton(
            icon: Icons.lightbulb_outline,
            label: '提示',
            onPressed: onHint,
          ),
          _ControlButton(icon: Icons.menu, label: '菜单', onPressed: onMenu),
          _ControlButton(
            icon: Icons.bar_chart,
            label: '分析',
            onPressed: onAnalysis,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.gold),
      label: Text(label, style: const TextStyle(color: AppColors.obsidianBlack)),
    );
  }
}
