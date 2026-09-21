import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Centered "game over" popup for a non-campaign match (vs Human or vs
/// AI) — the [message] (e.g. "红方胜！") used to only ever show as small
/// text in the info bar; this puts it front and center with a way to
/// dismiss or immediately play again.
class GameResultDialog extends StatelessWidget {
  final String message;
  final Palette palette;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const GameResultDialog({
    super.key,
    required this.message,
    required this.palette,
    required this.onClose,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: palette.scaffoldBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.pieceRim, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: palette.blockedX,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.blockedX,
                      side: BorderSide(color: palette.pieceRim),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('关闭 Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.appBarBackground,
                      foregroundColor: palette.scaffoldBackground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('再来一局 Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
