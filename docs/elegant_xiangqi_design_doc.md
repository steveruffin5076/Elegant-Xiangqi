# Elegant Traditional Xiangqi - Design Document
## For Android + Web | Player vs Computer + Campaign Mode

### VISION: "Imperial Silk & Jade"
Not another brown wooden board. Think **Forbidden City meets Apple design** - traditional materials rendered with modern elegance.

> Research shows players love the combination of ink painting + pixel art for "Oriental Wonders" aesthetic [Research](https://dl.acm.org/doi/10.1145/3746469.3746582) - we will push that to AAA quality.

---

### 1. VISUAL ART DESIGN - Traditional Yet Elegant

#### A. Core Philosophy: Material Truth
Instead of flat colors, use real scanned materials:

**Board:**
- Base: **Huanghuali wood** (黄花梨) - the imperial rosewood, golden-brown with flowing grain. This is already proven as a premium theme in Xiangqi Practice Assistant [2](https://deepwiki.com/qq978262947/-_-)
- River: Not blue paint, but **carved jade inlay** with subtle water ripple normal map. Inscribed with 楚河 汉界 in seal script calligraphy (like Song dynasty rubbings)
- Palace: **Gold leaf** diagonal lines, 3x3 with soft inner glow, like palace roof tiles
- Lines: Thin **ink brush** strokes, not perfect vector lines - slight pressure variation

**Pieces:**
- Material: **Hetian Jade** for Red (warm white), **Black Obsidian / Ink Stone** for Black. Edge with brass rim.
- Face: Not printed, but **intaglio engraved** Chinese characters (帅, 仕, 相...) with vermillion ink fill
- 3D Model: Slight dome (like real Xiangqi pieces), with subsurface scattering so light passes through jade
- Interaction: When selected, piece lifts with **silk shadow** and soft chime (bronze bell tone) [Research](https://dl.acm.org/doi/10.1145/3746469.3746582)

**Background & UI:**
- Background: **Rice paper (宣纸) texture** with very light ink wash mountains (留白 - negative space concept)
- Color Palette:
  - Primary: Ink Black #1A1A1A, Imperial Red #9B1B30, Jade White #F5F1E8
  - Accent: Gold #D4AF37, Celadon #A8C3B9
- Typography: **Noto Serif SC** for Chinese, **Crimson Text** for English - both elegant serif
- Animations: Ink diffusion when piece captured, cloud drift in background, paper fiber shimmer

#### B. 3 Premium Themes (Unlockable)
1.  **Huanghuali & Jade (Default)** - Warm, daytime, for beginners
2.  **Obsidian & Moonlight** - Dark mode, black stone board, pieces glow like moon jade - for night play [2]
3.  **Imperial Scroll** - Full ink wash painting mode - board is an unrolled scroll, pieces are ink blots that form characters when moved. Most artistic.

This alone is UNUSED - current Play Store apps are "antique chess game interface" but low-res [Play Store](https://play.google.com/store/apps/details?id=com.chinesechess.xiangqi.battle&hl=en_US). None use PBR jade + silk.

---

### 2. PLAYER VS COMPUTER - Difficulty System

We will use **Pikafish**, the strongest open-source Xiangqi engine derived from Stockfish [4](https://github.com/official-pikafish/Pikafish/blob/master/README.md). It supports UCI protocol, so we can control strength precisely.

#### Inspired by Xiangqi Master implementation [1](https://github.com/cuongleinc/xiangqi-master):

| Level | Title (Traditional Rank) | AI Think Time | Depth | Behavior | Player Skill |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | **童生 Tongsheng** (Village Child) | 50ms | 5 | Makes 1 blunder every 3 moves, ignores tactics | Absolute Beginner |
| 2 | **秀才 Xiucai** (Scholar) | 150ms | 8 | Plays solid, misses forks | Beginner |
| 3 | **举人 Juren** (Recommended Man) | 400ms | 10 | Good defense, weak attack | Casual |
| 4 | **贡士 Gongshi** (Tribute Scholar) | 800ms | 12 | Balanced, starts using Cannon control | Intermediate |
| 5 | **进士 Jinshi** (Presented Scholar) | 1500ms | 15 | Strong, uses opening book [1](https://github.com/cuongleinc/xiangqi-master) | Advanced |
| 6 | **翰林 Hanlin** (Imperial Academy) | 3000ms | 18 | Very strong, evaluation bar shows | Expert |
| 7 | **军师 Junshi** (Strategist - Zhuge Liang) | 5000ms | 22+ | Near perfect, uses NNUE network | Master |
| 8 | **棋圣 Qisheng** (Saint of Chess) | 8000ms+ | 25+ | Full Pikafish strength | Grandmaster |

**How to make Easy feel human (not just weak):**
- Don't just reduce time. At low levels, force AI to pick 2nd or 3rd best move 30% of time
- Add "Personality": Tongsheng loves moving Soldiers, Xiucai loves Horses, etc.
- Hint System: 3 hints per game [1], with elegant scroll opening animation
- Undo: Pair undo for PvC [1]
- Adaptive: If player loses 3x in a row, offer to lower difficulty (like Xiangqi.com did [3](https://www.xiangqi.com/releases))

**Implementation for Android/Web:**
- Web: `pikafish.wasm` runs locally offline [5](https://deepwiki.com/dffge552/xiangqi-pwa-offline) - no server cost
- Android: Native binary with auto CPU detection [6](https://github.com/Augus1217/Chinese-Chess)

---

### 3. CAMPAIGN MODE - "The Path from Pawn to General" (从卒到帅)

This is where you beat all competitors. No Xiangqi app has a real story campaign - they only have puzzles [3].

#### Overall Structure: 5 Chapters x 10 Battles = 50 Levels + 10 Secret Endgames
Total playtime: 6-8 hours, perfect for mobile.

**Narrative Frame:** You are a young scholar in Song Dynasty, where Xiangqi was finalized. You must travel from village to Imperial Palace, learning from masters.

**CHAPTER 1: 乡试 Village Trial (Tutorial - Levels 1-10)**
*Visual: Bamboo grove, rice paper board, morning light*
- Story: Your grandfather teaches you
- Opponents: Grandfather (Tongsheng), Village Kids
- Mechanics Taught: One piece per 2 levels (Chariot moves, then Horse leg block, then Elephant eye, then Cannon jump)
- Special Win Conditions: "Win by only using Horses", "Checkmate in 3 moves"
- Boss Level 10: Village Festival - beat 3 players in a row with limited time

**CHAPTER 2: 县试 County Tournament (Levels 11-20)**
*Visual: County yamen courtyard, Huanghuali board*
- Story: You enter county exam, meet rivals
- Opponents: Each has style - "The Aggressive Chariot", "The Defensive Elephant"
- New Mechanic: **Famous Opening** - Central Cannon vs Screen Horse [Wiki]
- Collectible: **Ancient Manual Fragments** - after each win, unlock a real historical endgame puzzle
- Boss Level 20: County Magistrate (Juren level) - must win with evaluation bar hidden

**CHAPTER 3: 会试 Capital Journey - Chu-Han War (Levels 21-35)**
*Visual: Battlefield, river becomes real Chu River with battle flags, jade board cracks slightly*
- Story: You dream you are general in Chu-Han Contention (the origin of 楚河 汉界 on board)
- This is the core - recreate 15 **historical famous games** from Song Dynasty manuals
- Each level starts mid-game from a real classic position
- Opponents: Xiang Yu (Black, aggressive), Liu Bang (Red, cunning) - their AI personalities differ
- Twist: **Fog of War** - some pieces hidden like ancient war (optional)
- Secret: Find all "War Drums" to unlock Obsidian theme

**CHAPTER 4: 殿试 Palace Examination (Levels 36-45)**
*Visual: Forbidden City, Gold leaf palace, silk curtains*
- Story: Emperor invites you to palace
- Opponents: Hanlin Academy scholars, each is a puzzle master
- Mechanic: **No Hints, No Undo** - pure skill
- Levels are **"Checkmate Challenges"** from Xiangqi.com's Puzzle Challenge [3] - e.g., "Mate in 5 with Horse + Cannon"
- Boss 45: The Emperor's Advisor (Hanlin level) - plays at 3000ms depth

**CHAPTER 5: 棋圣 Ascension (Levels 46-50)**
*Visual: Ink Wash Heaven - board floats on clouds, pieces are constellations*
- Final test vs 5 legendary ghosts of Xiangqi history
- Level 50 vs **"The Immortal"** - Pikafish at full strength, but you can use all scrolls collected
- Ending: You become Qisheng, your name carved on jade stele. Unlock Imperial Scroll theme + ability to create custom campaign levels.

#### Progression & Monetization (Elegant, not predatory)
- **Stars:** 1 star for win, 2 stars for win under move limit, 3 stars for perfect (no hints/undo)
- **Scroll Collection:** 108 classic endgames from ancient books - acts like puzzle mode [3]
- **Calligraphy Rewards:** Each chapter win unlocks a new calligraphy style for pieces (Seal Script, Clerical, Cursive)
- **Free:** Chapters 1-2 free, Chapters 3-5 one-time $2.99 "Imperial Edition" - very fair

#### Why This Campaign Works for Traditional Elegant
1.  It teaches Xiangqi's real history (Chu-Han river, Song dynasty final form)
2.  Each chapter's art evolves from simple bamboo to imperial gold - player *feels* progression visually
3.  Uses proven mechanics: puzzle challenge + bots with backstory [3]
4.  Perfect for Android/Web offline [5] - all levels work offline with WASM engine

---

### 4. Next Step - Prototype Plan

I can build you a playable web prototype TODAY with:

1.  Elegant Huanghuali + Jade board in HTML Canvas
2.  Pikafish WASM with 4 difficulty levels
3.  Chapter 1 (3 levels) of campaign with ink wash cutscenes

Want me to start coding it? Tell me which chapter you want first, and I will generate the premium board assets.
