import 'package:flutter/material.dart';

import '../game/piece.dart';
import 'piece_widget.dart';

class CapturedTray extends StatelessWidget {
  final List<Piece> pieces;

  const CapturedTray({super.key, required this.pieces});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final piece in pieces)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                width: 24,
                height: 24,
                child: PieceWidget(piece: piece),
              ),
            ),
        ],
      ),
    );
  }
}
