import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/shared_prefs_service.dart';

/// Controls light/dark mode for the whole app. The state IS the ThemeMode
/// itself — no separate state class needed since ThemeMode already covers
/// every value we care about (system mode is intentionally not used here;
/// Part M's settings toggle is an explicit light/dark switch).
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPrefsService _prefsService;

  ThemeCubit(this._prefsService) : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final isDark = await _prefsService.getDarkMode();
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    await _prefsService.setDarkMode(newMode == ThemeMode.dark);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await _prefsService.setDarkMode(mode == ThemeMode.dark);
  }
}
