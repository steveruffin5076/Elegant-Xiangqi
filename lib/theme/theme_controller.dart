import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'palette.dart';

/// Holds the active [AppTheme], persisted in the `settings` Hive box (per
/// the Phase 4 plan: "Store in settings box, toggle in menu").
///
/// This is a plain global singleton + [ChangeNotifier] rather than
/// Provider/InheritedWidget: some existing widget tests construct
/// [GameScreen] directly under a bare `MaterialApp` (not the full app
/// root), so anything relying on an ancestor provider would break there.
/// Widgets that need to react to theme changes wrap themselves in
/// `AnimatedBuilder(animation: themeController, ...)`.
class ThemeController extends ChangeNotifier {
  static const boxName = 'settings';
  static const _themeKey = 'theme';

  AppTheme _theme;

  ThemeController({AppTheme initial = AppTheme.huanghualiJade})
    : _theme = initial;

  AppTheme get theme => _theme;

  Palette get palette => _theme.palette;

  /// Applies a previously saved theme, opening the `settings` box if
  /// needed. Call once at startup; safe to skip in contexts (like most
  /// widget tests) that never touch theming.
  Future<void> loadSaved() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<dynamic>(boxName);
    }
    final box = Hive.box<dynamic>(boxName);
    final stored = box.get(_themeKey) as String?;
    if (stored == null) return;
    for (final candidate in AppTheme.values) {
      if (candidate.name == stored && candidate != _theme) {
        _theme = candidate;
        notifyListeners();
        break;
      }
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    if (theme == _theme) return;
    _theme = theme;
    notifyListeners();
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<dynamic>(boxName);
    }
    await Hive.box<dynamic>(boxName).put(_themeKey, theme.name);
  }
}

/// The app-wide theme controller. See class doc for why this is a plain
/// singleton instead of an Inherited/Provider value.
final themeController = ThemeController();
