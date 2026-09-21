import 'package:flutter/material.dart';

import '../game/campaign_data.dart';
import '../game/campaign_progress.dart';
import '../theme/colors.dart';
import 'game_screen.dart';

/// Vertical scroll ("手卷") campaign map: 5 chapters, 50 levels. Node
/// lock/star state comes from [CampaignProgress]. "Parallax mountains" /
/// hand-painted path art from the plan is Phase 4 polish — this is the
/// functional version: a continuous scroll, chapter sections, tappable
/// level nodes.
class CampaignMapScreen extends StatefulWidget {
  const CampaignMapScreen({super.key});

  @override
  State<CampaignMapScreen> createState() => _CampaignMapScreenState();
}

class _CampaignMapScreenState extends State<CampaignMapScreen> {
  Future<void> _openLevel(CampaignLevel level) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(campaignLevel: level)),
    );
    if (mounted) setState(() {}); // refresh lock/star state on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jadeWhite,
      appBar: AppBar(
        title: const Text('从卒到帅'),
        backgroundColor: AppColors.huanghuali,
        foregroundColor: AppColors.jadeWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          for (final chapter in campaignChapters)
            _ChapterSection(chapter: chapter, onTapLevel: _openLevel),
        ],
      ),
    );
  }
}

class _ChapterSection extends StatelessWidget {
  final CampaignChapter chapter;
  final ValueChanged<CampaignLevel> onTapLevel;

  const _ChapterSection({required this.chapter, required this.onTapLevel});

  @override
  Widget build(BuildContext context) {
    // Bamboo-green (Chapter 1) to palace-gold (Chapter 5), per the plan's
    // "long vertical ink wash painting" background note.
    final t = (chapter.number - 1) / 4;
    final bandColor = Color.lerp(
      const Color(0xFF6E8B5A),
      AppColors.gold,
      t,
    )!.withValues(alpha: 0.12);

    return Container(
      color: bandColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '第${chapter.number}章 · ${chapter.title}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidianBlack,
            ),
          ),
          Text(
            chapter.subtitle,
            style: const TextStyle(color: AppColors.obsidianBlack, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final level in chapter.levels)
                _LevelNode(level: level, onTap: () => onTapLevel(level)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final CampaignLevel level;
  final VoidCallback onTap;

  const _LevelNode({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unlocked = CampaignProgress.isUnlocked(level.overallIndex);
    final stars = CampaignProgress.starsFor(level.id);

    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.45,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.huanghuali,
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${level.levelInChapter}',
                    style: const TextStyle(
                      color: AppColors.jadeWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (!unlocked)
                    const Icon(
                      Icons.lock,
                      color: AppColors.jadeWhite,
                      size: 20,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Icon(
                    Icons.star,
                    size: 12,
                    color: i < stars ? AppColors.gold : AppColors.celadon,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
