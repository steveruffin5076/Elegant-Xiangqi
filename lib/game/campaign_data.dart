import 'board.dart';
import 'difficulty.dart';

class CampaignLevel {
  final String id; // "<chapter>-<levelInChapter>", e.g. "1-1"
  final int chapter;
  final int levelInChapter;
  final int overallIndex; // 0-based position across all 50 levels
  final String title;
  final String fen;
  final String opponentName;
  final Difficulty opponentDifficulty;
  final String description;

  const CampaignLevel({
    required this.id,
    required this.chapter,
    required this.levelInChapter,
    required this.overallIndex,
    required this.title,
    required this.fen,
    required this.opponentName,
    required this.opponentDifficulty,
    required this.description,
  });
}

class CampaignChapter {
  final int number;
  final String title;
  final String subtitle;
  final List<CampaignLevel> levels;

  const CampaignChapter({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.levels,
  });
}

/// Chapter 1 — 乡试 Village Trial: hand-built tutorial positions that
/// introduce one or two piece types at a time, per the design doc.
/// Reduced-material FENs rather than custom win-condition enforcement
/// (e.g. "win using only Horses") — validating exotic win conditions
/// programmatically was out of scope for this pass; see progress.md.
final _chapter1Levels = [
  CampaignLevel(
    id: '1-1',
    chapter: 1,
    levelInChapter: 1,
    overallIndex: 0,
    title: '认识车 Meet the Chariot',
    fen: 'r3k4/9/9/9/9/9/9/9/9/R3K3R w - - 0 1',
    opponentName: '爷爷 Grandfather',
    opponentDifficulty: difficulties[0],
    description: '车可直行直撞，一路杀到底。用双车击败爷爷吧。',
  ),
  CampaignLevel(
    id: '1-2',
    chapter: 1,
    levelInChapter: 2,
    overallIndex: 1,
    title: '车的对决 Chariot Duel',
    fen: 'r3k3r/9/9/9/9/9/9/9/9/R3K3R w - - 0 1',
    opponentName: '村里的孩子 Village Kid',
    opponentDifficulty: difficulties[0],
    description: '对手也有两只车了，小心正面交锋。',
  ),
  CampaignLevel(
    id: '1-3',
    chapter: 1,
    levelInChapter: 3,
    overallIndex: 2,
    title: '马的秘密 The Horse\'s Secret',
    fen: '1n2k4/9/9/9/9/9/9/9/9/1N2K2N1 w - - 0 1',
    opponentName: '村里的孩子 Village Kid',
    opponentDifficulty: difficulties[0],
    description: '马走日字，是最灵活的棋子之一。',
  ),
  CampaignLevel(
    id: '1-4',
    chapter: 1,
    levelInChapter: 4,
    overallIndex: 3,
    title: '别马腿 Blocking the Horse\'s Leg',
    fen: '4k4/9/9/9/9/9/4p4/4N4/9/4K4 w - - 0 1',
    opponentName: '爷爷 Grandfather',
    opponentDifficulty: difficulties[0],
    description: '马腿被别住就无法跳过——试着绕开卒子。',
  ),
  CampaignLevel(
    id: '1-5',
    chapter: 1,
    levelInChapter: 5,
    overallIndex: 4,
    title: '象的眼 The Elephant\'s Eye',
    fen: '2b1k4/9/9/9/9/9/9/9/9/2B1K1B2 w - - 0 1',
    opponentName: '村里的孩子 Village Kid',
    opponentDifficulty: difficulties[0],
    description: '象走田字，眼被塞住就动弹不得。',
  ),
  CampaignLevel(
    id: '1-6',
    chapter: 1,
    levelInChapter: 6,
    overallIndex: 5,
    title: '河的界限 The River\'s Limit',
    fen: '4k4/9/9/9/9/4p4/4P4/9/9/2B1K4 w - - 0 1',
    opponentName: '爷爷 Grandfather',
    opponentDifficulty: difficulties[0],
    description: '象不能过河，卒过河后可以左右移动。',
  ),
  CampaignLevel(
    id: '1-7',
    chapter: 1,
    levelInChapter: 7,
    overallIndex: 6,
    title: '炮打隔山 Cannon Fires Over the Mountain',
    fen: '1c2k4/9/9/9/9/1p7/9/9/9/1C2K2C1 w - - 0 1',
    opponentName: '村里的孩子 Village Kid',
    opponentDifficulty: difficulties[0],
    description: '炮吃子必须隔着一个棋子，平时移动则不能。',
  ),
  CampaignLevel(
    id: '1-8',
    chapter: 1,
    levelInChapter: 8,
    overallIndex: 7,
    title: '炮的实战 Cannon in Battle',
    fen: 'rc2k2cr/9/9/9/9/9/9/9/9/RC2K2CR w - - 0 1',
    opponentName: '爷爷 Grandfather',
    opponentDifficulty: difficulties[0],
    description: '车炮配合，是中局常见的攻击组合。',
  ),
  CampaignLevel(
    id: '1-9',
    chapter: 1,
    levelInChapter: 9,
    overallIndex: 8,
    title: '综合演练 Combined Practice',
    fen: 'rn2k2nr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1',
    opponentName: '村里的孩子 Village Kid',
    opponentDifficulty: difficulties[0],
    description: '综合运用所学，你的兵力比对手更完整。',
  ),
  CampaignLevel(
    id: '1-10',
    chapter: 1,
    levelInChapter: 10,
    overallIndex: 9,
    title: '乡试大比 Village Festival',
    fen: startingFen,
    opponentName: '村庄冠军 Village Champion',
    opponentDifficulty: difficulties[1],
    description: '标准棋局，双方全部兵力——乡试的最后一战！',
  ),
];

/// Chapters 2-5 use the standard starting position with escalating AI
/// strength (bespoke reduced-material puzzles/"historical" FENs and
/// custom win conditions for 40 levels were out of scope for this pass
/// — the design doc explicitly allows mocking; see progress.md).
List<CampaignLevel> _generateChapter({
  required int chapter,
  required int levelCount,
  required int startOverallIndex,
  required String flavorTitle,
  required List<String> opponentNames,
  required String bossName,
  required String description,
}) {
  return [
    for (var i = 0; i < levelCount; i++)
      CampaignLevel(
        id: '$chapter-${i + 1}',
        chapter: chapter,
        levelInChapter: i + 1,
        overallIndex: startOverallIndex + i,
        title: i == levelCount - 1 ? bossName : '$flavorTitle ${i + 1}',
        fen: startingFen,
        opponentName: i == levelCount - 1
            ? bossName
            : opponentNames[i % opponentNames.length],
        opponentDifficulty: _scaledDifficulty(startOverallIndex + i),
        description: description,
      ),
  ];
}

/// Spreads overall level index 10..49 across difficulty tiers 1..7 (tier
/// 0 is reserved for Chapter 1's easy tutorial levels).
Difficulty _scaledDifficulty(int overallIndex) {
  const first = 10;
  const last = 49;
  final t = (overallIndex - first) / (last - first);
  final tier = (1 + t * 6).round().clamp(1, 7);
  return difficulties[tier];
}

final List<CampaignChapter> campaignChapters = [
  CampaignChapter(number: 1, title: '乡试 Village Trial', subtitle: '竹林 · 晨光', levels: _chapter1Levels),
  CampaignChapter(
    number: 2,
    title: '县试 County Tournament',
    subtitle: '县衙庭院',
    levels: _generateChapter(
      chapter: 2,
      levelCount: 10,
      startOverallIndex: 10,
      flavorTitle: '县试对局',
      opponentNames: ['凶猛的车手 Aggressive Chariot', '稳健的象手 Defensive Elephant'],
      bossName: '县太爷 County Magistrate',
      description: '标准开局，对手棋力逐步提升。',
    ),
  ),
  CampaignChapter(
    number: 3,
    title: '会试 Capital Journey · 楚汉之争',
    subtitle: '楚河汉界',
    levels: _generateChapter(
      chapter: 3,
      levelCount: 15,
      startOverallIndex: 20,
      flavorTitle: '楚汉战局',
      opponentNames: ['项羽 Xiang Yu', '刘邦 Liu Bang'],
      bossName: '楚汉决战 The Final Battle',
      description: '标准开局，重现楚汉相争的气魄。',
    ),
  ),
  CampaignChapter(
    number: 4,
    title: '殿试 Palace Examination',
    subtitle: '紫禁金顶',
    levels: _generateChapter(
      chapter: 4,
      levelCount: 10,
      startOverallIndex: 35,
      flavorTitle: '殿试棋局',
      opponentNames: ['翰林学士 Hanlin Scholar'],
      bossName: '皇帝顾问 The Emperor\'s Advisor',
      description: '标准开局，殿前无悔棋、无提示，纯粹的较量。',
    ),
  ),
  CampaignChapter(
    number: 5,
    title: '棋圣 Ascension',
    subtitle: '云端棋局',
    levels: _generateChapter(
      chapter: 5,
      levelCount: 5,
      startOverallIndex: 45,
      flavorTitle: '传说对局',
      opponentNames: ['棋界幽魂 Legendary Ghost'],
      bossName: '不朽 The Immortal',
      description: '标准开局，棋圣殿堂的最终试炼。',
    ),
  ),
];

final List<CampaignLevel> allCampaignLevels = [
  for (final chapter in campaignChapters) ...chapter.levels,
];
