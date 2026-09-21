import 'package:flutter/material.dart';

/// A theme's full set of board/piece/chrome colors. Unlike [AppColors]
/// (the fixed "Imperial Silk & Jade" brand palette used for buttons/menus
/// across the app), a [Palette] is what actually changes between the 3
/// themes from the design doc — board wood/stone, river, pieces, and the
/// surrounding chrome.
@immutable
class Palette {
  final String name;
  final List<Color> boardGradient; // 3 stops, top-left to bottom-right
  final Color gridLines;
  final Color riverStart;
  final Color riverMid;
  final Color palaceGlow;
  final Color selectionRing;
  final Color legalDot;
  final Color blockedX;
  final Color redPieceGradientStart;
  final Color redPieceGradientEnd;
  final Color blackPieceGradientStart;
  final Color blackPieceGradientEnd;
  final Color pieceRim;
  final Color redPieceText;
  final Color blackPieceText;
  final Color scaffoldBackground;
  final Color appBarBackground;

  const Palette({
    required this.name,
    required this.boardGradient,
    required this.gridLines,
    required this.riverStart,
    required this.riverMid,
    required this.palaceGlow,
    required this.selectionRing,
    required this.legalDot,
    required this.blockedX,
    required this.redPieceGradientStart,
    required this.redPieceGradientEnd,
    required this.blackPieceGradientStart,
    required this.blackPieceGradientEnd,
    required this.pieceRim,
    required this.redPieceText,
    required this.blackPieceText,
    required this.scaffoldBackground,
    required this.appBarBackground,
  });
}

/// Default: warm Huanghuali wood + white jade, daytime.
const huanghualiJade = Palette(
  name: '黄花梨与玉 Huanghuali & Jade',
  boardGradient: [Color(0xFF9C6A38), Color(0xFF8B5A2B), Color(0xFF7A4B20)],
  gridLines: Color(0xFFD4AF37),
  riverStart: Color(0xFFF5F1E8),
  riverMid: Color(0xFFA8C3B9),
  palaceGlow: Color(0xFFD4AF37),
  selectionRing: Color(0xFFD4AF37),
  legalDot: Color(0xFF1A1A1A),
  blockedX: Color(0xFF9B1B30),
  redPieceGradientStart: Color(0xFFF5F1E8),
  redPieceGradientEnd: Color(0xFFE8E0D0),
  blackPieceGradientStart: Color(0xFF2E2E2E),
  blackPieceGradientEnd: Color(0xFF1A1A1A),
  pieceRim: Color(0xFFD4AF37),
  redPieceText: Color(0xFF9B1B30),
  blackPieceText: Color(0xFFF5F1E8),
  scaffoldBackground: Color(0xFFF5F1E8),
  appBarBackground: Color(0xFF8B5A2B),
);

/// Dark mode: black stone board, gold lines, pieces "glow like moon jade".
const obsidianMoonlight = Palette(
  name: '玄石月光 Obsidian & Moonlight',
  boardGradient: [Color(0xFF2A2A2A), Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
  gridLines: Color(0xFFD4AF37),
  riverStart: Color(0xFF3A4A4A),
  riverMid: Color(0xFF243333),
  palaceGlow: Color(0xFFD4AF37),
  selectionRing: Color(0xFFD4AF37),
  legalDot: Color(0xFFD4AF37),
  blockedX: Color(0xFFC23B54),
  redPieceGradientStart: Color(0xFFF5F1E8),
  redPieceGradientEnd: Color(0xFFD8CBA8),
  blackPieceGradientStart: Color(0xFF3A3A4A),
  blackPieceGradientEnd: Color(0xFF16161E),
  pieceRim: Color(0xFFD4AF37),
  redPieceText: Color(0xFFC23B54),
  blackPieceText: Color(0xFFE0D8C0),
  scaffoldBackground: Color(0xFF1A1A1A),
  appBarBackground: Color(0xFF2A2A2A),
);

/// Ink-wash scroll: board reads as unrolled parchment, ink-brush grid.
const imperialScroll = Palette(
  name: '御卷 Imperial Scroll',
  boardGradient: [Color(0xFFEDE0C8), Color(0xFFDCC9A0), Color(0xFFC9B183)],
  gridLines: Color(0xFF3A2E1F),
  riverStart: Color(0xFFB8A888),
  riverMid: Color(0xFF9E8B68),
  palaceGlow: Color(0xFF8B5A2B),
  selectionRing: Color(0xFF9B1B30),
  legalDot: Color(0xFF3A2E1F),
  blockedX: Color(0xFF9B1B30),
  redPieceGradientStart: Color(0xFFF5F1E8),
  redPieceGradientEnd: Color(0xFFE8E0D0),
  blackPieceGradientStart: Color(0xFF2E2E2E),
  blackPieceGradientEnd: Color(0xFF1A1A1A),
  pieceRim: Color(0xFFD4AF37),
  redPieceText: Color(0xFF9B1B30),
  blackPieceText: Color(0xFFF5F1E8),
  scaffoldBackground: Color(0xFFF0E6D2),
  appBarBackground: Color(0xFF8B5A2B),
);

enum AppTheme { huanghualiJade, obsidianMoonlight, imperialScroll }

extension AppThemeX on AppTheme {
  Palette get palette => switch (this) {
    AppTheme.huanghualiJade => huanghualiJade,
    AppTheme.obsidianMoonlight => obsidianMoonlight,
    AppTheme.imperialScroll => imperialScroll,
  };
}
