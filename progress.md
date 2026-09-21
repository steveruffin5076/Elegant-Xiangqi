# Progress - Elegant Xiangqi

Tracks implementation status against `claude_code_development_plan.md`.

## Status: Phase 2 complete

You can now play vs AI at 8 difficulty levels (menu → 人机对战), with
hints, undo, and a material eval bar. The "AI" is a local heuristic
search, not real Pikafish yet — see the Phase 2 entry below for why and
what a future swap-in needs to preserve.

## Phases

- [x] **Phase 0 - Project Foundation**: Flutter project init, folder structure,
      portrait board rendering (9x10), touch input, rules engine skeleton
      - `lib/game/piece.dart`, `board.dart`, `rules.dart`: full move
        generation for all 7 piece types, FEN parse/export, check +
        flying-general + checkmate detection
      - `lib/widgets/board_widget.dart`: CustomPainter board (wood, gold
        lines, jade river, palace diagonals) + tap-to-select/move
      - `lib/screens/game_screen.dart`: portrait layout per
        `portrait_mode_design.md` (6+4+62+4+8+10+6)
      - `lib/engine/pikafish.dart`: stub returning a random legal move
      - `test/game/rules_test.dart`: 14 unit tests covering horse leg
        block, elephant eye/river, cannon screen capture, soldier
        river-crossing, check/flying-general, checkmate
      - `flutter analyze` clean, `flutter test` (16/16 pass),
        `flutter build web --release` succeeds
- [x] **Phase 1 - Elegant Art + Piece Interaction**: Huanghuali board art, jade/
      obsidian piece rendering, select/move/capture animations, legal move dots
      - `lib/widgets/board_widget.dart`: wood gradient (standing in for a
        PBR texture), river with jade/celadon gradient + gold Noto Serif SC
        "楚河 汉界", palace diagonals with a blurred gold-leaf glow pass
      - `lib/widgets/piece_widget.dart`: radial jade/obsidian gradients,
        brass (gold) rim, Noto Serif SC bold characters, select = 1.1x
        scale + gold glow (220ms easeOutCubic, unchanged from Phase 0)
      - `lib/widgets/visual_piece.dart`: gives each piece a stable id so
        `AnimatedPositioned` can slide it 220ms easeOutCubic between
        squares instead of popping — board_widget/game_screen now track
        `VisualPiece` list instead of reading the raw grid directly
      - `lib/widgets/ink_splash.dart` (`CaptureInkSplash` — renamed to
        avoid clashing with Flutter's own `InkSplash`): 10-dot ink
        diffusion burst plays on capture, auto-removes itself
      - Invalid-move feedback: tapping an unreachable square while a
        piece is selected triggers a shake animation on it (covers
        "Elephant cannot cross river" from the plan); selecting a Horse
        additionally shows a red X on any leg square currently blocking
        it (`Rules.horseBlockedLegs`)
      - "Bronze bell" chime on select is a `debugPrint` per the plan
        ("just print for now") — real audio lands in Phase 4
      - Deliberate deviation from the plan: piece capture/particle uses a
        plain `CustomPainter` + `AnimationController`, not the Flame
        particle system — Flame stays a pubspec dependency for later
        (board rendering / AI-vs-AI playback) but wiring a `GameWidget`
        into this screen just for one particle effect wasn't worth the
        complexity yet
      - `google_fonts` is live for the real app (Noto Serif SC); tests
        disable runtime font fetching via `test/flutter_test_config.dart`
        so `flutter test` stays offline/deterministic
      - Added `test/screens/game_screen_test.dart`: end-to-end tap tests
        (select → legal move → turn switches; select → illegal tap →
        deselects without moving) through the real widget tree, not just
        the rules engine
      - `flutter analyze` clean, `flutter test` (18/18 pass),
        `flutter build web --release` succeeds
- [x] **Phase 2 - Pikafish AI + Difficulty Levels**: WASM/native engine
      integration, 8 difficulty levels, eval bar, hints, undo
      - **Not real Pikafish.** Wiring the actual WASM/native engine needs
        a browser (for JS interop + COOP/COEP headers for threaded WASM)
        or an Android device to verify against, and neither is available
        in this sandbox — shipping untested JS-bridge code claimed as
        "working" would be worse than being upfront about a placeholder.
        `lib/engine/pikafish.dart` keeps the plan's intended file/class
        name and async `getBestMove(board, difficulty)` signature as the
        seam a real engine drops into later; today it's backed by a local
        alpha-beta search (material eval, capture-first move ordering,
        iterative deepening) instead.
      - `lib/game/difficulty.dart`: the 8 traditional ranks (童生 →
        棋圣) with movetime from the design doc. Since `Board.legalMoves`
        does a full check-simulation per candidate (expensive), true
        search depth is capped low (1–3 plies, `searchDepth` per level)
        rather than matching Pikafish's real target depths (5–25) —
        those numbers become meaningful once the real engine replaces
        this stand-in. Weaker levels additionally have a `blunderChance`
        (up to 50% at 童生) to pick a lower-ranked move on purpose, per
        the design doc's "don't just reduce time" guidance.
      - Fixed a real bug while wiring this up: `Board.isGameOver` was
        missing — Xiangqi has no stalemate *draw* (a side with zero legal
        moves loses whether or not it's in check), but the UI only ever
        checked `isCheckmate`, so a true stalemate would have softlocked
        the board. Added `isGameOver` and used it everywhere a game-end
        check happens.
      - `lib/screens/home_screen.dart` / `difficulty_select_screen.dart`:
        reachable via the in-game "菜单" (Menu) button (kept `main.dart`'s
        default `home` as a direct human-vs-human `GameScreen` so
        existing Phase 0/1 tests didn't need to change). Difficulty cards
        are plain list tiles for now — "ink painting card" art is Phase 4.
      - `game_screen.dart`: human is always Red, AI always Black (no side
        picker yet); AI move triggers automatically via the same
        `_makeMove` path a human tap uses, so captures/ink-splash/check
        messages all work unmodified for AI moves. Added a snapshot-based
        undo (stores full state before each move rather than trying to
        invert a move) — one Undo press reverts 2 plies in vs-AI games
        (the AI's reply + the human's move) so the human always lands
        back on their own turn, or 1 ply in human-vs-human. Hint (3 per
        game) asks the engine for the current side's best move and shows
        a pulsing gold dot (`PulsingDot`) on the from/to squares for 3s.
      - Eval bar now shows live material balance (`Pikafish.
        evaluateMaterialForRed`, normalized by ~max material of 48).
      - Tests: `test/engine/pikafish_test.dart` (difficulty table shape,
        engine returns null with no legal moves, prefers a free capture,
        *avoids* a capture that loses to a defended recapture — this one
        specifically exercises that depth>1 lookahead beats greedy
        1-ply eval, search finishes well under a timing budget,
        material eval sanity); `test/screens/home_flow_test.dart`
        (menu → difficulty select → game navigation; AI actually replies
        after a human move, verified through the real widget tree).
      - `flutter analyze` clean, `flutter test` (28/28 pass),
        `flutter build web --release` succeeds
- [ ] **Phase 3 - Campaign Mode**: Hive save setup, campaign map screen (5
      chapters x 10 levels), campaign data, result screen
- [ ] **Phase 4 - Polish + Android + Web Build**: sounds, 3 themes,
      performance pass, release builds, app icons

## Notes

- Update this file as phases complete; check off items and add dated notes
  below.
