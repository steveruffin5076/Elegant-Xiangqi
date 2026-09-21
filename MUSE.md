# CLAUDE.md - Elegant Xiangqi Project Context

This file is read by Claude Code on startup. It defines project rules.

## Project: Elegant Xiangqi - Imperial Silk & Jade
Portrait-mode Chinese Chess for Android + Web, one codebase.

## Vision
Premium traditional, not cheap antique. Huanghuali wood board, Hetian jade + obsidian pieces, rice paper ink wash background. 8 difficulty levels using Pikafish WASM, 5-chapter campaign (50 levels) "从卒到帅".

## Tech Stack - DECIDED
**Flutter + Flame Engine** (best for portrait + Android + Web from one codebase)
- Flutter 3.22+ for UI
- Flame 1.18+ for board rendering / particle effects
- pikafish.wasm for AI (via flutter_js or wasm_interop)
- Hive for local save (campaign progress, settings)
- Provider / Riverpod for state

Alternative if user prefers Web-first: React + PixiJS + Capacitor (but Flutter is primary)

## Key Files
- `portrait_mode_design.md` - Exact layout spec, must follow 6%+4%+62%+4%+8%+10%+6%
- `elegant_xiangqi_design_doc.md` - Full art + AI + campaign design
- `lib/engine/pikafish.dart` - WASM wrapper
- `lib/game/board.dart` - 9x10 board logic, FEN, move validation
- `assets/board/` - PBR textures

## Coding Rules for Claude Code
1. **Portrait First**: All UI must be portrait 9:16, max width 480px on web. Use SafeArea.
2. **No External Backend**: AI must run offline via WASM. No Firebase needed for MVP.
3. **Material Truth**: Use real material colors: Huanghuali #8B5A2B, Jade #F5F1E8, Gold #D4AF37, Imperial Red #9B1B30, Ink Black #1A1A1A, Celadon #A8C3B9
4. **Elegant Animation**: 220ms easeOutCubic for piece moves, ink splash on capture, silk shadow on lift
5. **Pikafish Integration**: Use `go movetime X` for difficulty levels: 50,150,400,800,1500,3000,5000,8000 ms
6. **Campaign Save**: Hive box `campaign_progress` with chapter, level, stars (1-3)
7. **Performance**: 60fps on low-end Android, avoid heavy shaders. Use Canvas, not WebGL for board if possible.
8. **Progress Tracking**: Always update `progress.md` with current status, what changed, and any important notes/deviations from plan — after finishing a phase or making a significant change, before ending the session.

## Current Phase
Phase 1: Elegant art + piece interaction

## Commands
- `flutter run -d chrome` for web
- `flutter run -d android` for Android
- `flutter build web --web-renderer canvaskit`
- `flutter build apk --release`

## Reference Implementations
- Xiangqi Master: https://github.com/cuongleinc/xiangqi-master (Pikafish difficulty logic)
- Pikafish WASM: https://github.com/official-pikafish/Pikafish
- Board themes: Huanghuali, Obsidian from xiangqi-pwa-offline
