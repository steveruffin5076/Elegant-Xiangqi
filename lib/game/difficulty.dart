/// The 8 traditional-rank difficulty levels from
/// docs/elegant_xiangqi_design_doc.md. `movetimeMs` mirrors the "think
/// time" a real Pikafish `go movetime` call will eventually use once the
/// real WASM/native engine replaces the local heuristic one in
/// lib/engine/pikafish.dart; `searchDepth` and `blunderChance` tune that
/// stand-in engine today (see its doc comment for why depth is capped low).
class Difficulty {
  final int level;
  final String title;
  final int movetimeMs;
  final int searchDepth;
  final double blunderChance;

  const Difficulty({
    required this.level,
    required this.title,
    required this.movetimeMs,
    required this.searchDepth,
    required this.blunderChance,
  });
}

const List<Difficulty> difficulties = [
  Difficulty(
    level: 1,
    title: '童生 Tongsheng',
    movetimeMs: 50,
    searchDepth: 1,
    blunderChance: 0.5,
  ),
  Difficulty(
    level: 2,
    title: '秀才 Xiucai',
    movetimeMs: 150,
    searchDepth: 1,
    blunderChance: 0.35,
  ),
  Difficulty(
    level: 3,
    title: '举人 Juren',
    movetimeMs: 400,
    searchDepth: 2,
    blunderChance: 0.25,
  ),
  Difficulty(
    level: 4,
    title: '贡士 Gongshi',
    movetimeMs: 800,
    searchDepth: 2,
    blunderChance: 0.15,
  ),
  Difficulty(
    level: 5,
    title: '进士 Jinshi',
    movetimeMs: 1500,
    searchDepth: 2,
    blunderChance: 0.05,
  ),
  Difficulty(
    level: 6,
    title: '翰林 Hanlin',
    movetimeMs: 3000,
    searchDepth: 3,
    blunderChance: 0.0,
  ),
  Difficulty(
    level: 7,
    title: '军师 Junshi',
    movetimeMs: 5000,
    searchDepth: 3,
    blunderChance: 0.0,
  ),
  Difficulty(
    level: 8,
    title: '棋圣 Qisheng',
    movetimeMs: 8000,
    searchDepth: 3,
    blunderChance: 0.0,
  ),
];
