# Progress - Elegant Xiangqi

Tracks implementation status against `claude_code_development_plan.md`.

## Status: Phase 4 complete (web release-ready; Android APK not buildable here)

Real sound effects, 3 selectable themes, a generated app icon/splash
screen, board-render performance passes, and a portrait-centered desktop
web build all landed. `flutter build web --release` succeeds and is the
actual deliverable from this sandbox. `flutter build apk --release` is
NOT possible here — see the Phase 4 entry below for the concrete blocker
(the Android SDK can't be installed: `dl.google.com` is denied by this
environment's egress proxy) and what to do on a machine that has it.

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
- [x] **Phase 3 - Campaign Mode**: Hive save setup, campaign map screen (5
      chapters x 50 levels total per the design doc — 10+10+15+10+5),
      campaign data, result screen
      - **Scope cut, documented honestly**: the plan's exotic per-level
        win conditions ("win using only Horses", "checkmate in 3") and
        Chapter 3's "historical famous games" needed either a win-
        condition engine (tracking move count / restricting which piece
        types may move) or verified real historical FENs — neither was
        feasible to do honestly in this pass (no way to verify a
        "historical" FEN's authenticity without a source I could check).
        The plan explicitly allows mocking here ("50 campaign levels,
        even if some FENs mocked"). What's real: Chapter 1's 10 levels
        are hand-built, reduced-material tutorial positions (one/two
        piece types at a time, matching the design doc's teaching
        progression) verified by `Board.fromFen` + `isGameOver` checks
        in a test, not just typed by hand and trusted. Chapters 2-5 (40
        levels) reuse the standard starting position with AI difficulty
        scaled smoothly from tier 1 to tier 7 across the arc — real,
        distinct, winnable games with real progression, just not
        hand-authored puzzles.
      - `lib/game/campaign_data.dart`: `CampaignLevel`/`CampaignChapter`
        models; `allCampaignLevels` flattens all 50 for iteration.
      - `lib/game/campaign_progress.dart`: Hive-backed persistence (best
        star count per level id, a single linear "unlocked count" rather
        than per-chapter gating, matching the map's one continuous
        scroll). `main.dart` calls `Hive.initFlutter()` then
        `CampaignProgress.init()` before `runApp`; tests use plain
        `Hive.init(tempDir)` instead since `initFlutter` needs
        path_provider's platform channel, unavailable under `flutter
        test`.
      - `lib/screens/campaign_map_screen.dart`: one continuous
        `ListView` of 5 chapter bands (green-to-gold tint by chapter
        number, standing in for the plan's "vertical ink wash painting"
        — actual painted art + parallax mountains is Phase 4), each with
        its level nodes; locked nodes show a lock icon over the level
        number (dimmed) rather than a separate art asset.
      - `game_screen.dart`: new `campaignLevel` param loads the level's
        FEN and difficulty (overriding `aiDifficulty`). On game-over,
        computes stars (3 = won with 0 hints/undos used, 2 = won with
        ≤2 combined, 1 = any other win, 0 = loss), records via
        `CampaignProgress.recordResult`, and shows
        `CampaignResultDialog` (ink-stamp 胜/负 + gold star seals, per
        the plan) with a button back to the map.
      - Tests: `test/game/campaign_data_test.dart` (all 50 FENs parse,
        both generals present, Red to move, not already over, ids
        unique, difficulty non-decreasing); `test/game/
        campaign_progress_test.dart` (Hive round-trip: fresh state,
        recording a win unlocks the next level, a worse replay never
        lowers stars, a loss doesn't unlock); `test/screens/
        campaign_flow_test.dart` (menu → map → locked level does
        nothing, unlocked level opens the real game, through the actual
        widget tree). Found and fixed a real off-by-one in
        `CampaignProgress.recordResult` this way (it compared
        `overallIndex + 1` against `unlockedCount` instead of
        `overallIndex + 2`, so winning never actually unlocked
        anything) — caught by the Hive round-trip test, not by reading
        the code.
      - `flutter analyze` clean, `flutter test` (37/37 pass),
        `flutter build web --release` succeeds
- [x] **Phase 4 - Polish + Android + Web Build**: sounds, 3 themes,
      performance pass, release builds, app icons
      - **Android APK: not buildable in this sandbox, confirmed and
        documented rather than skipped silently.** `flutter doctor`
        already showed no Android SDK; installing one needs
        `dl.google.com` (SDK components AND the Android Gradle plugin's
        Maven dependencies both come from there), and this environment's
        egress proxy denies that host outright (`CONNECT tunnel failed,
        response 403`) — confirmed directly, not assumed. Ran `flutter
        build apk --release` anyway to get the real error on record:
        `No Android SDK found`. The Android project itself (gradle
        files, manifest, generated launcher icons/splash) is otherwise
        release-shaped from `flutter create` plus the generators below;
        someone with SDK access should be able to `flutter build apk
        --release` directly. `flutter build web --release` **does**
        succeed here and is what this pass actually verifies end to end.
      - **Sounds**: real (if simple) synthesized WAV effects, not
        silence — `assets/audio/{bell,rustle,splash}.wav`, generated
        with pure Python stdlib (`wave`/`struct`/`math`, no deps): a
        decaying 2-harmonic sine "bell" for select, a low-pass-filtered
        noise burst for the move "rustle", noise+thump for the capture
        "splash". `lib/audio/audio_service.dart` wraps `audioplayers`;
        every call swallows its own errors (audio is non-critical, and
        a headless/test environment has no real audio backend) so it
        can never crash or block a move. Replaces the Phase 1 `debugPrint`
        placeholder for the select chime.
      - **3 themes**: `lib/theme/palette.dart` defines `Palette` (board
        gradient, grid/river/palace colors, piece gradients+rim+text,
        scaffold/app-bar background) with 3 const instances —
        Huanghuali & Jade (default), Obsidian & Moonlight (dark, black
        stone board + gold lines + glowing pieces), Imperial Scroll
        (parchment board, ink-black grid). `lib/theme/theme_controller.dart`
        is a **plain global `ChangeNotifier` singleton**, not
        Provider/InheritedWidget — deliberately, because a couple of
        existing widget tests construct `GameScreen` directly under a
        bare `MaterialApp` rather than the full app root, and anything
        relying on an ancestor provider would have broken there.
        Widgets that need to react wrap themselves in
        `AnimatedBuilder(animation: themeController, ...)`. Persisted in
        the `settings` Hive box the plan called for back in Phase 3.
        New `lib/screens/settings_screen.dart` (reachable via Home →
        主题) lists the 3 themes; picking one updates board/piece/chrome
        colors live.
      - Found and fixed a real test-infra deadlock while adding the
        settings flow test: `Hive.deleteFromDisk()` in `tearDown` hung
        forever when it raced a still-in-flight fire-and-forget Hive
        write from the theme-card tap earlier in the same test. Root-
        caused with a minimal repro (bisected by deleting pieces of the
        test until the hang disappeared), not guessed at — the fix was
        to stop redundantly resetting the theme in `tearDown` (the
        single-test file doesn't need cross-test cleanup for a
        process-wide singleton anyway).
      - **Performance**: `RepaintBoundary` around the board's
        `CustomPaint` (isolates the ~static board texture from piece/
        splash/hint animation repaints) and around each `PieceWidget`
        (isolates one piece's shake/scale from its neighbors) — real
        code-level changes, but actual FPS on a device could not be
        profiled in this sandbox (no display, no Android device).
      - **App icon + splash**: generated for real, not placeholders —
        `assets/icon/app_icon.png`/`splash_logo.png`, drawn with Python/
        Pillow (huanghuali-brown rounded square, jade-white disc, gold
        brass rim) with a genuine 象 glyph from a Noto Serif SC subset
        font fetched live from Google Fonts (no CJK font was available
        locally to render it otherwise). Wired through
        `flutter_launcher_icons` (Android + web icons) and
        `flutter_native_splash` (Android + web splash screens), both of
        which ran and regenerated the actual platform asset files —
        verify the result in `android/app/src/main/res/mipmap-*/` and
        `web/icons/`.
      - **Web portrait frame**: `web/index.html` gets a `@media
        (min-width: 481px)` rule constraining `<body>` to max-width
        480px, centered, with a rice-paper-toned gradient behind it —
        relies on Flutter web's documented behavior of filling its
        nearest positioned ancestor (here, `<body>`) at 100%, but
        **not visually verified**: this sandbox has no browser/display
        to check it in.
      - `flutter analyze` clean, `flutter test` (42/42 pass),
        `flutter build web --release` succeeds

## Post-launch polish (after Phase 4, PR #1 merged)

- **GitHub Pages deployment** (PR #2, merged): added
  `.github/workflows/deploy-pages.yml`, which builds
  `flutter build web --release --base-href /Elegant-Xiangqi/` and
  publishes it via `actions/deploy-pages` on every push to `main`.
  Live URL: https://steveruffin5076.github.io/Elegant-Xiangqi/ — build
  confirmed green on GitHub Actions. Requires the one-time repo setting
  Settings → Pages → Source = "GitHub Actions" (can't be set from this
  sandbox; needs a repo admin).
- **Launch screen fix**: `lib/main.dart` was sending players straight
  into a human-vs-human `GameScreen` on cold start instead of
  `HomeScreen` (the actual main menu with vs-Human / vs-AI / Campaign /
  Theme). Changed `home:` to `const HomeScreen()`. Updated the 5 widget
  tests that assumed the old behavior (`widget_test.dart`,
  `game_screen_test.dart`, `home_flow_test.dart`,
  `settings_flow_test.dart`, `campaign_flow_test.dart`) to navigate via
  the real menu instead of relying on the app opening directly into a
  game.
- **Smoother move animation**: pieces already slid between squares
  (220ms `easeOutCubic`, unchanged), but a capture just vanished
  instantly and a moving piece looked flat. Added:
  - A "lift" while a piece is mid-slide (`PieceWidget.lifted`): scales
    to 1.12x and casts a bigger, offset shadow, so the move reads as
    picking the piece up and setting it down rather than gliding flat.
    Tracked via `movingPieceId` in `_GameScreenState`, cleared 220ms
    after the move via a `Future.delayed`.
  - Captured pieces now fade + shrink out over 220ms at the square
    they were taken on, instead of disappearing instantly. Implemented
    as `BoardWidget.ghostPieces` — frozen `VisualPiece` snapshots kept
    *outside* the interactive `visualPieces` list (so they can't be
    mistaken for the piece that just captured them, and can't intercept
    taps), cleared via an `onGhostFadeComplete` callback once the fade
    finishes (same pattern as the existing ink-splash `activeSplashes`).
- `flutter analyze` clean, `flutter test` (42/42 pass),
  `flutter build web --release` succeeds.
- **Centered game-over popup** (non-campaign games): "红方胜！"/"黑方胜！"
  used to only show as small text in the bottom info bar. Added
  `lib/widgets/game_result_dialog.dart` (`GameResultDialog`), a centered
  modal with 关闭 Close (dismiss, board stays frozen — it was already
  game-over) and 再来一局 Retry (resets to a fresh match of the same
  kind via the new `_resetGame()` in `game_screen.dart`, reusing the
  opponent/difficulty already in play). Campaign games are unaffected —
  they still use the existing `CampaignResultDialog` with stars. Info
  bar text is unchanged/still shown alongside the popup.
  `flutter analyze` clean, `flutter test` (43/43 pass),
  `flutter build web --release` succeeds.
- **Removed the duplicate win/loss text** below the board, and **slowed
  the move animation**: the info bar previously repeated "红方胜！"/
  "黑方胜！" underneath the new centered popup — `statusMessage` no
  longer gets set to that text on game over (still shows "将军!" for
  check, as before). The 220ms move slide/lift/capture-fade felt too
  quick — bumped to 380ms via a new shared `lib/theme/motion.dart`
  (`pieceMoveDuration`), replacing the repeated `220` magic number
  across `board_widget.dart`, `piece_widget.dart`, and the
  `movingPieceId` clear timer in `game_screen.dart`, so all of it stays
  in lockstep.
  `flutter analyze` clean, `flutter test` (43/43 pass),
  `flutter build web --release` succeeds.

## Notes

- Update this file as phases complete; check off items and add dated notes
  below.
