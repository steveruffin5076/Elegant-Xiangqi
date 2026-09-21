import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/palette.dart';
import '../theme/theme_controller.dart';

/// The 3 premium themes from the design doc. Board/piece art itself is
/// themed (see board_widget.dart / piece_widget.dart); this screen just
/// lets the player pick one, persisted via [ThemeController].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final current = themeController.theme;
        return Scaffold(
          backgroundColor: AppColors.jadeWhite,
          appBar: AppBar(
            title: const Text('主题 Theme'),
            backgroundColor: AppColors.huanghuali,
            foregroundColor: AppColors.jadeWhite,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final theme in AppTheme.values)
                _ThemeCard(
                  theme: theme,
                  selected: theme == current,
                  onTap: () => themeController.setTheme(theme),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = theme.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.celadon.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: palette.boardGradient),
                    border: Border.all(color: palette.gridLines, width: 2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    palette.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.obsidianBlack,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? AppColors.gold : AppColors.celadon,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
