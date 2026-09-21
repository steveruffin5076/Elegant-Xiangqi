import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'campaign_map_screen.dart';
import 'difficulty_select_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

/// Minimal mode-select menu, reached from the in-game "菜单" (Menu)
/// button. Full main-menu art direction is Phase 4 polish; this just
/// needs to route to a human-vs-human or human-vs-AI game.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jadeWhite,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '象棋',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.imperialRed,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elegant Xiangqi',
                  style: TextStyle(color: AppColors.obsidianBlack, fontSize: 16),
                ),
                const SizedBox(height: 48),
                _MenuButton(
                  label: '双人对战  Play vs Human',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  label: '人机对战  Play vs AI',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DifficultySelectScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  label: '闯关模式  Campaign',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CampaignMapScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  label: '主题  Theme',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.huanghuali,
          foregroundColor: AppColors.jadeWhite,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
