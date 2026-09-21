# Progress - Elegant Xiangqi

Tracks implementation status against `claude_code_development_plan.md`.

## Status: Phase 0 complete

Flutter project scaffolded (`flutter create --platforms=android,web`), full
Xiangqi rules engine implemented and unit-tested, portrait board renders
and is playable human-vs-human (no AI, no art polish yet — that's Phase 1).

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
- [ ] **Phase 1 - Elegant Art + Piece Interaction**: Huanghuali board art, jade/
      obsidian piece rendering, select/move/capture animations, legal move dots
- [ ] **Phase 2 - Pikafish AI + Difficulty Levels**: WASM/native engine
      integration, 8 difficulty levels, eval bar, hints, undo
- [ ] **Phase 3 - Campaign Mode**: Hive save setup, campaign map screen (5
      chapters x 10 levels), campaign data, result screen
- [ ] **Phase 4 - Polish + Android + Web Build**: sounds, 3 themes,
      performance pass, release builds, app icons

## Notes

- Update this file as phases complete; check off items and add dated notes
  below.
