# Progress - Elegant Xiangqi

Tracks implementation status against `claude_code_development_plan.md`.

## Status: Phase 1 complete

Board and pieces now have real art direction (wood gradient, jade/obsidian
piece gradients, Noto Serif SC characters, glowing palace, ink river), and
moves/captures animate. Still human-vs-human only — AI is Phase 2.

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
- [ ] **Phase 2 - Pikafish AI + Difficulty Levels**: WASM/native engine
      integration, 8 difficulty levels, eval bar, hints, undo
- [ ] **Phase 3 - Campaign Mode**: Hive save setup, campaign map screen (5
      chapters x 10 levels), campaign data, result screen
- [ ] **Phase 4 - Polish + Android + Web Build**: sounds, 3 themes,
      performance pass, release builds, app icons

## Notes

- Update this file as phases complete; check off items and add dated notes
  below.
