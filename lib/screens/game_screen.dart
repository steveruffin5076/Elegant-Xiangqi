import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/piece.dart';
import '../game/rules.dart';
import '../theme/colors.dart';
import '../widgets/board_widget.dart';
import '../widgets/captured_tray.dart';
import '../widgets/control_bar.dart';
import '../widgets/eval_bar.dart';
import '../widgets/visual_piece.dart';

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
  List<BoardPosition> blockedLegs = [];
  final List<Piece> capturedByRed = [];
  final List<Piece> capturedByBlack = [];
  String? statusMessage;

  late List<VisualPiece> visualPieces;
  int _nextPieceId = 0;
  int _nextSplashId = 0;
  final Map<int, BoardPosition> activeSplashes = {};

  int? shakingPieceId;
  int shakeSeed = 0;

  @override
  void initState() {
    super.initState();
    visualPieces = [
      for (var r = 0; r < Board.rows; r++)
        for (var c = 0; c < Board.cols; c++)
          if (board.squares[r][c] != null)
            VisualPiece(
              id: _nextPieceId++,
              piece: board.squares[r][c]!,
              position: BoardPosition(r, c),
            ),
    ];
  }

  VisualPiece _visualPieceAt(BoardPosition pos) =>
      visualPieces.firstWhere((p) => p.position == pos);

  void _onTapSquare(BoardPosition pos) {
    if (selected != null) {
      if (legalDestinations.contains(pos)) {
        _makeMove(BoardMove(selected!, pos));
        return;
      }

      final tappedPiece = board.pieceAt(pos);
      if (tappedPiece != null && tappedPiece.side == board.turn) {
        _select(pos);
        return;
      }

      // Tapped an illegal destination while a piece was selected — shake it
      // (covers a hobbled horse, an elephant blocked at the river, etc.).
      final shakenId = _visualPieceAt(selected!).id;
      setState(() {
        shakingPieceId = shakenId;
        shakeSeed++;
        selected = null;
        legalDestinations = [];
        blockedLegs = [];
      });
      return;
    }

    final tappedPiece = board.pieceAt(pos);
    if (tappedPiece != null && tappedPiece.side == board.turn) {
      _select(pos);
    }
  }

  void _select(BoardPosition pos) {
    debugPrint('bronze bell chime (piece selected)');
    final piece = board.pieceAt(pos)!;
    setState(() {
      selected = pos;
      legalDestinations = board.legalMoves(pos).map((m) => m.to).toList();
      blockedLegs = piece.type == PieceType.horse
          ? Rules.horseBlockedLegs(board, pos)
          : [];
    });
  }

  void _makeMove(BoardMove move) {
    final capturedPiece = board.pieceAt(move.to);
    final moverSide = board.pieceAt(move.from)!.side;
    final nextBoard = board.applyMove(move);

    final movingVisual = _visualPieceAt(move.from);
    final capturedVisual = capturedPiece == null
        ? null
        : visualPieces.firstWhere(
            (p) => p.position == move.to && p.id != movingVisual.id,
          );

    setState(() {
      board = nextBoard;
      selected = null;
      legalDestinations = [];
      blockedLegs = [];
      shakingPieceId = null;

      if (capturedVisual != null) {
        visualPieces.remove(capturedVisual);
        activeSplashes[_nextSplashId++] = move.to;
        if (moverSide == Side.red) {
          capturedByRed.add(capturedPiece!);
        } else {
          capturedByBlack.add(capturedPiece!);
        }
      }

      movingVisual.position = move.to;

      if (board.isCheckmate) {
        statusMessage = moverSide == Side.red ? '红方胜！' : '黑方胜！';
      } else if (board.isInCheck(board.turn)) {
        statusMessage = '将军!';
      } else {
        statusMessage = null;
      }
    });
  }

  void _onSplashComplete(int id) {
    setState(() => activeSplashes.remove(id));
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
                    pieces: visualPieces,
                    selected: selected,
                    legalDestinations: legalDestinations,
                    blockedLegs: blockedLegs,
                    shakingPieceId: shakingPieceId,
                    shakeSeed: shakeSeed,
                    activeSplashes: activeSplashes,
                    onSplashComplete: _onSplashComplete,
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
