# Portrait Mode Design - Elegant Xiangqi
## Optimized for Android 1080x2400 + Web Mobile

### Why Portrait is Superior for Xiangqi
Xiangqi board is 9 files x 10 ranks = tall rectangle (0.9 aspect). In landscape, you waste side space. In portrait, board fills screen naturally. All top Xiangqi apps use portrait.

### Layout Structure (Top to Bottom) - 100vh

```
+-----------------------------------+
|  STATUS BAR (6% - 56dp)           |
|  [Black: 棋圣]  Timer  Eval Bar    |
+-----------------------------------+
|  CAPTURED TRAY BLACK (4%)         |
|  ● ● ●  (small jade pieces)      |
+-----------------------------------+
|                                   |
|  BOARD AREA (62% - core)          |
|  +-- Huanghuali Board 9x10 -------+|
|  |  Palace gold leaf, jade river || 
|  |  Pieces: jade + obsidian      || 
|  +-- with ink wash shadow -------+|
|                                   |
+-----------------------------------+
|  CAPTURED TRAY RED (4%)           |
|  ● ●                              |
+-----------------------------------+
|  INFO PANEL (8%)                  |
|  Last Move: 炮二平五  |  Check!    |
+-----------------------------------+
|  CONTROL BAR (10%)                |
|  [Undo] [Hint 3] [Menu] [Analysis]|
+-----------------------------------+
|  BOTTOM NAV (6% - Android)        |
|  Campaign | Play | Puzzles | Skins |
+-----------------------------------+
```

#### Detailed Specs

**1. Status Bar (6%)**
- Left: Opponent avatar (ink circle) + Title + Rank badge
- Center: Timer (if timed) or Chapter info "会试 23/50"
- Right: Evaluation bar vertical (thin gold bar, -10 to +10) + Settings gear
- Background: Rice paper with subtle grain

**2. Board Area (62%) - The Hero**
- Board width = 94% screen width, height auto to maintain 9:10 ratio
- Centered horizontally, 16dp side margins
- Drop shadow: soft ink diffusion, 24dp blur, 12dp offset
- River: 8% of board height, white jade with gold calligraphy, slightly raised (bevel)
- Coordinates: Traditional Chinese on side (九八七...) in seal script, very light opacity 30%
- Piece size: 9.5% of board width, with 2dp brass rim + subsurface glow
- Animation: Piece lifts 8dp with silk shadow, moves with easeOutCubic 220ms, capture = ink splash particle

**3. Info Panel (8%)**
- Left: Move notation in Chinese (马八进七) + classification dot (Best/Mistake)
- Right: Game state "将军!" in Imperial Red with pulse
- Background: Semi-transparent celadon #A8C3B9 15%

**4. Control Bar (10%)**
- 4 large touch targets (min 48dp) for thumb reach:
  - Undo: Arrow + "悔棋" - disabled if no moves
  - Hint: Scroll icon + "3" counter - opens elegant scroll animation
  - Menu: Pause / Resign / Draw
  - Analysis: Toggle eval bar
- Style: Jade buttons with gold border, haptic feedback

**5. Bottom Nav (6%) - For Campaign App**
- Only in main menu / campaign mode, hidden during game (swipe up to show)
- Icons: Custom ink brush icons

### Portrait Campaign Map Design
Instead of horizontal world map, use **Vertical Scroll Painting (手卷)**:
- User scrolls up (like climbing to palace) through 5 chapters
- Each chapter is a section of a long vertical ink painting
- Level nodes are temples/pavilions along the path
- Parallax: Mountains move slower than foreground

### Web Portrait Adaptation
- On desktop, show portrait phone frame centered (like mobile game preview)
- Max width 480px, centered, with rice paper background filling rest
- On mobile web, 100vw same as Android

### Safe Areas & Notch
- Top padding: statusBarHeight + 8dp
- Bottom: navigationBarHeight + 16dp for thumb
- Use `SafeArea` in Flutter, `env(safe-area-inset-*)` in CSS

### Art Assets Needed for Portrait
1. board_huanghuali_9x10.png @1x,2x,3x (PBR: albedo + normal + roughness)
2. piece_jade_white.png + piece_obsidian_black.png + brass rim mask
3. river_jade_inlay.png
4. bg_rice_paper_portrait.png (1080x2400 tileable)
5. ink_splash_particle.png
6. eval_bar_gold.png

### Interaction Flow - Portrait Thumb Zone
- All primary actions in bottom 30% (easy thumb)
- Board interaction: Tap to select, tap to move. No drag needed (better for big pieces)
- Long press piece = show legal moves with ink dots
