import 'package:flutter/material.dart';

import '../game/difficulty.dart';
import '../theme/colors.dart';
import 'game_screen.dart';

/// Vertical list of the 8 traditional-rank difficulty levels. Full "ink
/// painting card" art direction is Phase 4 polish; this wires the real
/// selection → game flow.
class DifficultySelectScreen extends StatelessWidget {
  const DifficultySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jadeWhite,
      appBar: AppBar(
        title: const Text('选择难度 Select Difficulty'),
        backgroundColor: AppColors.huanghuali,
        foregroundColor: AppColors.jadeWhite,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: difficulties.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _DifficultyCard(
          difficulty: difficulties[index],
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;

  const _DifficultyCard({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.celadon.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameScreen(aiDifficulty: difficulty),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.obsidianBlack,
                child: Text('${difficulty.level}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  difficulty.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.obsidianBlack,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.huanghuali),
            ],
          ),
        ),
      ),
    );
  }
}
