import 'package:flutter/material.dart';

import '../engine/pikafish.dart';
import '../game/board.dart';
import '../game/difficulty.dart';
import '../game/piece.dart';
import '../game/rules.dart';
import '../theme/colors.dart';
import '../widgets/board_widget.dart';
import '../widgets/captured_tray.dart';
import '../widgets/control_bar.dart';
import '../widgets/eval_bar.dart';
import '../widgets/visual_piece.dart';
import 'home_screen.dart';

/// A reasonably strong fixed setting used for Hint in human-vs-human
/// games (where there's no [Difficulty] already chosen), with a minimal
/// movetime so hints feel instant rather than waiting out a "think time".
const _hintDifficulty = Difficulty(
  level: 0,
  title: 'Hint',
  movetimeMs: 1,
  searchDepth: 3,
  blunderChance: 0.0,
);

const _totalHints = 3;

/// Portrait layout per docs/portrait_mode_design.md:
/// 6% status + 4% captured(black) + 62% board + 4% captured(red)
/// + 8% info + 10% controls. Bottom nav (6%) is hidden during a game.
class GameScreen extends StatefulWidget {
  /// Null means human-vs-human; otherwise the human (Red) plays the AI
  /// (Black) at this difficulty.
  final Difficulty? aiDifficulty;

  const GameScreen({super.key, this.aiDifficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameSnapshot {
  final Board board;
  final List<VisualPiece> visualPieces;
  final List<Piece> capturedByRed;
  final List<Piece> capturedByBlack;
  final String? statusMessage;

  _GameSnapshot({
    required this.board,
    required this.visualPieces,
    required this.capturedByRed,
    required this.capturedByBlack,
    required this.statusMessage,
  });
}

class _GameScreenState extends State<GameScreen> {
  static const humanSide = Side.red;

  final Pikafish _engine = Pikafish();
  final List<_GameSnapshot> _history = [];

  Board board = Board.initial();
  BoardPosition? selected;
  List<BoardPosition> legalDestinations = [];
  List<BoardPosition> blockedLegs = [];
  List<Piece> capturedByRed = [];
  List<Piece> capturedByBlack = [];
  String? statusMessage;

  late List<VisualPiece> visualPieces;
  int _nextPieceId = 0;
  int _nextSplashId = 0;
  final Map<int, BoardPosition> activeSplashes = {};

  int? shakingPieceId;
  int shakeSeed = 0;

  bool isAiThinking = false;
  int hintsRemaining = _totalHints;
  BoardPosition? hintFrom;
  BoardPosition? hintTo;

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

  bool get _isAiTurn =>
      widget.aiDifficulty != null && board.turn != humanSide;

  VisualPiece _visualPieceAt(BoardPosition pos) =>
      visualPieces.firstWhere((p) => p.position == pos);

  void _onTapSquare(BoardPosition pos) {
    if (board.isGameOver || isAiThinking || _isAiTurn) return;

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

  void _pushSnapshot() {
    _history.add(
      _GameSnapshot(
        board: board,
        visualPieces: [
          for (final v in visualPieces)
            VisualPiece(id: v.id, piece: v.piece, position: v.position),
        ],
        capturedByRed: List<Piece>.from(capturedByRed),
        capturedByBlack: List<Piece>.from(capturedByBlack),
        statusMessage: statusMessage,
      ),
    );
  }

  void _makeMove(BoardMove move) {
    _pushSnapshot();

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
      hintFrom = null;
      hintTo = null;

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

      if (board.isGameOver) {
        statusMessage = moverSide == Side.red ? '红方胜！' : '黑方胜！';
      } else if (board.isInCheck(board.turn)) {
        statusMessage = '将军!';
      } else {
        statusMessage = null;
      }
    });

    _maybeTriggerAiMove();
  }

  void _maybeTriggerAiMove() {
    final difficulty = widget.aiDifficulty;
    if (difficulty == null || board.turn == humanSide || board.isGameOver) {
      return;
    }
    _playAiMove(difficulty);
  }

  Future<void> _playAiMove(Difficulty difficulty) async {
    setState(() => isAiThinking = true);
    final move = await _engine.getBestMove(board, difficulty);
    if (!mounted) return;
    setState(() => isAiThinking = false);
    if (move != null) {
      _makeMove(move);
    }
  }

  Future<void> _onHint() async {
    if (hintsRemaining <= 0 || board.isGameOver || isAiThinking) return;
    final difficulty = widget.aiDifficulty ?? _hintDifficulty;
    final move = await _engine.getBestMove(board, difficulty);
    if (!mounted || move == null) return;
    setState(() {
      hintsRemaining--;
      hintFrom = move.from;
      hintTo = move.to;
    });
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (hintFrom == move.from && hintTo == move.to) {
        setState(() {
          hintFrom = null;
          hintTo = null;
        });
      }
    });
  }

  void _onUndo() {
    if (_history.isEmpty || isAiThinking) return;
    // In vs-AI games, one Undo reverts both the AI's reply and the human's
    // move that provoked it, so the human always lands back on their turn.
    final popCount = widget.aiDifficulty != null ? 2 : 1;
    _GameSnapshot? target;
    for (var i = 0; i < popCount && _history.isNotEmpty; i++) {
      target = _history.removeLast();
    }
    if (target == null) return;
    setState(() {
      board = target!.board;
      visualPieces = target.visualPieces;
      capturedByRed = target.capturedByRed;
      capturedByBlack = target.capturedByBlack;
      statusMessage = target.statusMessage;
      selected = null;
      legalDestinations = [];
      blockedLegs = [];
      shakingPieceId = null;
      hintFrom = null;
      hintTo = null;
      activeSplashes.clear();
    });
  }

  void _onSplashComplete(int id) {
    setState(() => activeSplashes.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final evalScore = _engine.evaluateMaterialForRed(board);
    return Scaffold(
      backgroundColor: AppColors.jadeWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: _StatusBar(
                turn: board.turn,
                thinking: isAiThinking,
                evalValue: (evalScore / 48).clamp(-1.0, 1.0),
              ),
            ),
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
                    hintFrom: hintFrom,
                    hintTo: hintTo,
                  ),
                ),
              ),
            ),
            Expanded(flex: 4, child: CapturedTray(pieces: capturedByRed)),
            Expanded(flex: 8, child: _InfoPanel(message: statusMessage)),
            Expanded(
              flex: 10,
              child: ControlBar(
                onUndo: _history.isEmpty ? null : _onUndo,
                onHint: hintsRemaining <= 0 ? null : _onHint,
                hintsRemaining: hintsRemaining,
                onMenu: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
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
  final bool thinking;
  final double evalValue;

  const _StatusBar({
    required this.turn,
    required this.thinking,
    required this.evalValue,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.huanghuali.withValues(alpha: 0.08),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            thinking
                ? '对方思考中…'
                : (turn == Side.red ? '红方走棋' : '黑方走棋'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.obsidianBlack,
            ),
          ),
          const Spacer(),
          EvalBar(value: evalValue),
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
