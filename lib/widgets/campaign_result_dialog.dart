import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// "Elegant rice paper modal" result screen per the Phase 3 plan: an ink
/// stamp for win/loss and stars as gold seals.
class CampaignResultDialog extends StatelessWidget {
  final bool won;
  final int stars;
  final VoidCallback onBackToMap;

  const CampaignResultDialog({
    super.key,
    required this.won,
    required this.stars,
    required this.onBackToMap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.jadeWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.gold, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: won ? AppColors.imperialRed : AppColors.obsidianBlack,
                  width: 3,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                won ? '胜' : '负',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: won ? AppColors.imperialRed : AppColors.obsidianBlack,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              won ? '胜利！' : '再接再厉',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.obsidianBlack,
              ),
            ),
            if (won) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    Icon(
                      Icons.star,
                      size: 32,
                      color: i < stars ? AppColors.gold : AppColors.celadon,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBackToMap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.huanghuali,
                  foregroundColor: AppColors.jadeWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('返回地图 Back to Map'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
