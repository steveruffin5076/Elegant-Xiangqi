import 'package:flutter/material.dart';

import '../audio/audio_service.dart';
import '../engine/pikafish.dart';
import '../game/board.dart';
import '../game/campaign_data.dart';
import '../game/campaign_progress.dart';
import '../game/difficulty.dart';
import '../game/piece.dart';
import '../game/rules.dart';
import '../theme/palette.dart';
import '../theme/theme_controller.dart';
import '../widgets/board_widget.dart';
import '../widgets/campaign_result_dialog.dart';
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
  /// (Black) at this difficulty. Ignored when [campaignLevel] is set —
  /// the level supplies its own opponent difficulty.
  final Difficulty? aiDifficulty;

  /// When set, this is a campaign game: the board loads from the level's
  /// FEN, the opponent plays at the level's difficulty, and a win/loss
  /// records progress and shows [CampaignResultDialog].
  final CampaignLevel? campaignLevel;

  const GameScreen({super.key, this.aiDifficulty, this.campaignLevel});

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
  final AudioService _audio = AudioService();
  final List<_GameSnapshot> _history = [];

  late Board board;
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

  /// Captured pieces still fading out at the square they were taken on —
  /// see [BoardWidget.ghostPieces].
  final Map<int, VisualPiece> fadingGhosts = {};

  /// Id of the piece currently sliding to a new square, for the "lift"
  /// shadow in [PieceWidget]. Cleared once the slide animation finishes.
  int? movingPieceId;

  int? shakingPieceId;
  int shakeSeed = 0;

  bool isAiThinking = false;
  int hintsRemaining = _totalHints;
  int undosUsed = 0;
  BoardPosition? hintFrom;
  BoardPosition? hintTo;

  Difficulty? get _aiDifficulty =>
      widget.campaignLevel?.opponentDifficulty ?? widget.aiDifficulty;

  @override
  void initState() {
    super.initState();
    board = widget.campaignLevel != null
        ? Board.fromFen(widget.campaignLevel!.fen)
        : Board.initial();
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

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  bool get _isAiTurn => _aiDifficulty != null && board.turn != humanSide;

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
    _audio.playSelect();
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

    if (capturedPiece != null) {
      _audio.playCapture();
    } else {
      _audio.playMove();
    }

    setState(() {
      board = nextBoard;
      selected = null;
      legalDestinations = [];
      blockedLegs = [];
      shakingPieceId = null;
      hintFrom = null;
      hintTo = null;
      movingPieceId = movingVisual.id;

      if (capturedVisual != null) {
        visualPieces.remove(capturedVisual);
        fadingGhosts[capturedVisual.id] = VisualPiece(
          id: capturedVisual.id,
          piece: capturedVisual.piece,
          position: move.to,
        );
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

    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      if (movingPieceId == movingVisual.id) {
        setState(() => movingPieceId = null);
      }
    });

    if (board.isGameOver) {
      _handleCampaignGameOver(moverSide);
    } else {
      _maybeTriggerAiMove();
    }
  }

  void _onGhostFadeComplete(int id) {
    setState(() => fadingGhosts.remove(id));
  }

  void _handleCampaignGameOver(Side moverSide) {
    final level = widget.campaignLevel;
    if (level == null) return;

    final won = moverSide == humanSide;
    final hintsUsed = _totalHints - hintsRemaining;
    final stars = !won
        ? 0
        : (hintsUsed == 0 && undosUsed == 0)
        ? 3
        : (hintsUsed + undosUsed <= 2)
        ? 2
        : 1;

    CampaignProgress.recordResult(
      levelId: level.id,
      overallIndex: level.overallIndex,
      stars: stars,
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CampaignResultDialog(
        won: won,
        stars: stars,
        onBackToMap: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // back to campaign map
        },
      ),
    );
  }

  void _maybeTriggerAiMove() {
    final difficulty = _aiDifficulty;
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
    final difficulty = _aiDifficulty ?? _hintDifficulty;
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
    final popCount = _aiDifficulty != null ? 2 : 1;
    _GameSnapshot? target;
    for (var i = 0; i < popCount && _history.isNotEmpty; i++) {
      target = _history.removeLast();
    }
    if (target == null) return;
    setState(() {
      undosUsed++;
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
      fadingGhosts.clear();
      movingPieceId = null;
    });
  }

  void _onSplashComplete(int id) {
    setState(() => activeSplashes.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) => _build(context, themeController.palette),
    );
  }

  Widget _build(BuildContext context, Palette palette) {
    final evalScore = _engine.evaluateMaterialForRed(board);
    final level = widget.campaignLevel;
    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      appBar: level == null
          ? null
          : AppBar(
              title: Text(level.title),
              backgroundColor: palette.appBarBackground,
              foregroundColor: palette.scaffoldBackground,
            ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: _StatusBar(
                turn: board.turn,
                thinking: isAiThinking,
                evalValue: (evalScore / 48).clamp(-1.0, 1.0),
                palette: palette,
              ),
            ),
            Expanded(
              flex: 4,
              child: CapturedTray(pieces: capturedByBlack, palette: palette),
            ),
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
                    movingPieceId: movingPieceId,
                    ghostPieces: fadingGhosts.values.toList(),
                    onGhostFadeComplete: _onGhostFadeComplete,
                    palette: palette,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: CapturedTray(pieces: capturedByRed, palette: palette),
            ),
            Expanded(
              flex: 8,
              child: _InfoPanel(message: statusMessage, palette: palette),
            ),
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
  final Palette palette;

  const _StatusBar({
    required this.turn,
    required this.thinking,
    required this.evalValue,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: palette.appBarBackground.withValues(alpha: 0.12),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            thinking
                ? '对方思考中…'
                : (turn == Side.red ? '红方走棋' : '黑方走棋'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: palette.blockedX,
            ),
          ),
          const Spacer(),
          EvalBar(value: evalValue, palette: palette),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String? message;
  final Palette palette;

  const _InfoPanel({required this.message, required this.palette});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: palette.riverMid.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          message ?? '',
          style: TextStyle(
            color: palette.blockedX,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
