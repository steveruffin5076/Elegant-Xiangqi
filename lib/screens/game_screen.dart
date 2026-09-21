import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/piece.dart';
import '../theme/colors.dart';
import '../widgets/board_widget.dart';
import '../widgets/captured_tray.dart';
import '../widgets/control_bar.dart';
import '../widgets/eval_bar.dart';

/// Portrait layout per docs/portrait_mode_design.md:
/// 6% status + 4% captured(black) + 62% board + 4% captured(red)
/// + 8% info + 10% controls. Bottom nav (6%) is hidden during a game.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Board board = Board.initial();
  BoardPosition? selected;
  List<BoardPosition> legalDestinations = [];
  final List<Piece> capturedByRed = [];
  final List<Piece> capturedByBlack = [];
  String? statusMessage;

  void _onTapSquare(BoardPosition pos) {
    if (selected != null && legalDestinations.contains(pos)) {
      _makeMove(BoardMove(selected!, pos));
      return;
    }

    final tappedPiece = board.pieceAt(pos);
    if (tappedPiece != null && tappedPiece.side == board.turn) {
      setState(() {
        selected = pos;
        legalDestinations = board.legalMoves(pos).map((m) => m.to).toList();
      });
    } else {
      setState(() {
        selected = null;
        legalDestinations = [];
      });
    }
  }

  void _makeMove(BoardMove move) {
    final captured = board.pieceAt(move.to);
    final mover = board.pieceAt(move.from)!;
    final nextBoard = board.applyMove(move);
    setState(() {
      board = nextBoard;
      selected = null;
      legalDestinations = [];
      if (captured != null) {
        if (mover.side == Side.red) {
          capturedByRed.add(captured);
        } else {
          capturedByBlack.add(captured);
        }
      }
      if (board.isCheckmate) {
        statusMessage = mover.side == Side.red ? '红方胜！' : '黑方胜！';
      } else if (board.isInCheck(board.turn)) {
        statusMessage = '将军!';
      } else {
        statusMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jadeWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(flex: 6, child: _StatusBar(turn: board.turn)),
            Expanded(flex: 4, child: CapturedTray(pieces: capturedByBlack)),
            Expanded(
              flex: 62,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: BoardWidget(
                    board: board,
                    selected: selected,
                    legalDestinations: legalDestinations,
                    onTapSquare: _onTapSquare,
                  ),
                ),
              ),
            ),
            Expanded(flex: 4, child: CapturedTray(pieces: capturedByRed)),
            Expanded(flex: 8, child: _InfoPanel(message: statusMessage)),
            Expanded(
              flex: 10,
              child: ControlBar(
                onUndo: null,
                onHint: null,
                onMenu: null,
                onAnalysis: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final Side turn;

  const _StatusBar({required this.turn});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.huanghuali.withValues(alpha: 0.08),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            turn == Side.red ? '红方走棋' : '黑方走棋',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.obsidianBlack,
            ),
          ),
          const Spacer(),
          const EvalBar(),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String? message;

  const _InfoPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.celadon.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          message ?? '',
          style: const TextStyle(
            color: AppColors.imperialRed,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
