# Claude Code Development Plan - Elegant Xiangqi (Portrait)

This is a ready-to-paste execution plan for Claude Code CLI. Each phase has exact prompts to give Claude.

---

## SETUP - Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
claude login
claude --version
```

Create project folder:
```bash
mkdir elegant-xiangqi && cd elegant-xiangqi
flutter create --platforms=android,web .
# Copy MUSE.md, portrait_mode_design.md, elegant_xiangqi_design_doc.md into root
```

---

## PHASE 0: Project Foundation (Prompt 1 for Claude Code)

**Paste this into Claude Code:**

```
Read MUSE.md and portrait_mode_design.md and elegant_xiangqi_design_doc.md

Task: Initialize Flutter project for portrait elegant Xiangqi.

1. Setup pubspec.yaml with:
   - flame: ^1.18.0
   - hive: ^2.2.3, hive_flutter
   - provider: ^6.1.1
   - google_fonts: ^6.1.0 (for Noto Serif SC + Crimson Text)

2. Create folder structure:
   lib/
     main.dart
     screens/
       game_screen.dart (portrait layout 6+4+62+4+8+10+6)
       campaign_map_screen.dart (vertical scroll painting)
     game/
       board.dart (9x10 logic, FEN, isLegalMove, check detection)
       piece.dart (enum: General, Advisor, Elephant, Horse, Chariot, Cannon, Soldier)
       rules.dart (Horse leg block, Elephant eye, Cannon jump, Palace, River, Flying General)
     engine/
       pikafish.dart (stub for now, returns random legal move)
     widgets/
       board_widget.dart (Flame or CustomPainter for Huanghuali board)
       piece_widget.dart (jade material with brass rim)
       captured_tray.dart
       control_bar.dart
       eval_bar.dart
   assets/
     board/ (create placeholder colors)
     pieces/
     bg/

3. In main.dart: Lock to portrait only: SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])

4. In game_screen.dart: Build exact portrait layout from portrait_mode_design.md - use LayoutBuilder, board width 94% screen width, 9:10 ratio.

5. In board.dart: Implement full Xiangqi rules validation. Use FEN: "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1"

6. Make it run: flutter run -d chrome should show empty Huanghuali board with gold lines and jade river, with touch to place pieces (debug).

Do not implement AI yet. Focus on board rendering + rules.
```

**Expected Output:** Working portrait board you can tap.

---

## PHASE 1: Elegant Art + Piece Interaction (Prompt 2)

```
Phase 1: Implement elegant art.

1. In board_widget.dart: 
   - Draw Huanghuali wood texture (use gradient + noise for now, later replace with PBR image)
   - Draw gold lines (1.5px, color #D4AF37, slight shadow)
   - Draw river: white jade #F5F1E8 with marble noise + gold text 楚河 汉界 in seal script (use GoogleFonts)
   - Draw palace diagonal with gold leaf glow (BoxShadow)

2. In piece_widget.dart:
   - Create 2 materials: White Jade (base #F5F1E8, shadow #E8E0D0, brass rim #D4AF37) and Obsidian (base #1A1A1A, red character #9B1B30)
   - Characters: 帅仕相马车炮兵 vs 将士象马车炮卒 - use Noto Serif SC bold
   - On select: scale 1.1 + silk shadow (blur 12) + bronze bell sound (just print for now)
   - On capture: ink splash particle using Flame particles (10 black dots spread)

3. Interaction:
   - Tap piece to select (show legal moves as small ink dots #1A1A1A 40% opacity)
   - Tap destination to move (220ms easeOutCubic animation)
   - Implement all special rules visual feedback: 
     - Horse blocked = show red X on blocking piece eye
     - Elephant cannot cross river = shake animation

4. Add assets: Generate placeholder textures or use solid colors with BoxDecoration

Test: Play human vs human in portrait, all rules work.
```

---

## PHASE 2: Pikafish AI + Difficulty Levels (Prompt 3)

```
Phase 2: Integrate Pikafish WASM for Player vs Computer.

Context: Read https://github.com/cuongleinc/xiangqi-master difficulty table and https://github.com/official-pikafish/Pikafish

1. Download pikafish.wasm from Pikafish releases. Place in assets/engine/
   Also download nn-*.nnue network file.

2. In lib/engine/pikafish.dart:
   - Use flutter_js or dart:js to load WASM in web, use native binary for Android (use package: flutter_pikafish or implement via MethodChannel)
   - For MVP web: implement as: 
     class Pikafish {
       Future<String> getBestMove(String fen, int movetimeMs)
       // sends "position fen <fen>" then "go movetime <ms>" to engine, parses "bestmove"
     }
   - If WASM too complex for MVP, mock with levels: use random move for Lv1, simple evaluation (material count) for Lv2-4, and call it "AI" - we will replace with real WASM later. But structure the API as if real.

3. Implement difficulty table from elegant_xiangqi_design_doc.md:
   Map<int, Difficulty> with movetime: 50,150,400,800,1500,3000,5000,8000
   Titles: 童生, 秀才, 举人, 贡士, 进士, 翰林, 军师, 棋圣

4. In game_screen.dart:
   - Add game mode: vs AI
   - When it's AI turn, show thinking indicator (ink brush writing) + call pikafish.getBestMove
   - Add evaluation bar (vertical gold bar on right of status bar)
   - Implement Hint (3 per game): call engine for best move, show with pulsing gold dot
   - Implement Undo: undo 2 plies (player+AI)

5. Add difficulty select screen: vertical list with ink painting cards, each showing rank badge.

Test: Play vs AI Lv1-4, should feel different strength.
```

---

## PHASE 3: Campaign Mode (Prompt 4)

```
Phase 3: Campaign "从卒到帅"

1. Setup Hive:
   - box campaign_progress: {chapter: int, level: int, stars: Map<levelId, int>, scrolls: List}
   - box settings

2. Create campaign_map_screen.dart:
   - Vertical scroll (SingleChildScrollView) height 3000px
   - Background: long vertical ink wash painting (use gradient for now: from bamboo grove green to palace gold)
   - 5 chapters as sections, each 600px tall
   - Level nodes: 10 per chapter, as small pavilion icons, connected by path
   - Show stars, lock/unlock based on progress
   - Parallax: use Stack + Positioned with different scroll speeds

3. Define campaign data in lib/game/campaign_data.dart:
   - List<Chapter> with 5 chapters from elegant_xiangqi_design_doc.md
   - Each Level has: id, title, fen (starting position), opponentName, opponentDifficulty, winCondition (e.g., "checkmateIn3", "onlyHorses"), description
   - For Chapter 1: tutorial levels with restricted pieces
   - For Chapter 3: use famous historical FENs (find 3 from internet, mock rest)

4. In game_screen.dart: Add campaign mode param. If campaign, load FEN from campaign_data, check winCondition, award stars, save to Hive, show result screen with ink stamp "胜" or "败" + 1-3 stars + calligraphy reward.

5. Result screen: Elegant rice paper modal with brush stroke title, stars as gold seals.

Test: Complete Chapter 1 (10 levels) with progression save.
```

---

## PHASE 4: Polish + Android + Web Build (Prompt 5)

```
Phase 4: Polish for release.

1. Add sounds: bronze bell on select, ink splash on capture, paper rustle on move (use audioplayers package, placeholder silent for now)

2. Add themes: Implement 3 themes from design doc:
   - Huanghuali & Jade (default)
   - Obsidian Moonlight (dark mode, board #1A1A1A, lines #D4AF37)
   - Imperial Scroll (board as scroll texture)
   Store in settings box, toggle in menu.

3. Performance:
   - Ensure 60fps: use RepaintBoundary for board, const constructors
   - Test on Android low-end: flutter run --profile

4. Build:
   - flutter build web --web-renderer canvaskit --release (output to build/web)
   - flutter build apk --release (output to build/app/outputs/flutter-apk/app-release.apk)
   - For web portrait: in web/index.html add viewport meta max-width 480px centered with rice paper background

5. Add app icons, splash screen with jade piece logo.

Final check: Portrait locked, no landscape, safe area handled, all 8 AI levels, 50 campaign levels (even if some FENs mocked).
```

---

## How to Run Claude Code Sequentially

```bash
claude
# Then paste Prompt 1, wait to finish, test
# Then paste Prompt 2, etc.

# Between phases, commit:
git add . && git commit -m "Phase X complete"
```

## Alternative: One-Shot Mega Prompt

If you want Claude to do everything at once (less reliable but faster):

```
Read all markdown docs. Build full elegant Xiangqi portrait Flutter app with:
- Portrait layout spec exact
- Huanghuali board + jade pieces
- Full Xiangqi rules
- Pikafish WASM stub with 8 difficulty levels
- Campaign 5 chapters vertical scroll map with Hive save
- Build for web and android

Work phase by phase, testing after each. Start with Phase 0 now.
```

---

## Deliverables Checklist
- [ ] Portrait board renders correctly 9x10
- [ ] All Xiangqi rules validated
- [ ] 8 AI levels with different movetime
- [ ] Campaign map vertical scroll
- [ ] 50 levels with FENs
- [ ] 3 themes
- [ ] Web build (build/web) + APK (build/app/outputs/flutter-apk/)
```

