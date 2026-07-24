import 'package:shared_preferences/shared_preferences.dart';

/// Single wrapper around SharedPreferences so no other file ever calls
/// `SharedPreferences.getInstance()` directly. Keeps key names in one
/// place and makes it trivial to swap the storage backend later.
///
/// Covers onboarding + theme now (needed by Part C); notification and
/// language preferences are stubbed in for when Part P / M are built.
class SharedPrefsService {
  static const String _kOnboardingComplete = 'onboarding_complete';
  static const String _kDarkMode = 'dark_mode';
  static const String _kNotificationsEnabled = 'notifications_enabled';
  static const String _kLanguage = 'language';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // --- Onboarding (Part C) ---

  Future<bool> getOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(_kOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_kOnboardingComplete, value);
  }

  // --- Theme (Part B / M) ---

  Future<bool> getDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_kDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await _prefs;
    await prefs.setBool(_kDarkMode, isDark);
  }

  // --- Notifications (Part M/P) ---

  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_kNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_kNotificationsEnabled, enabled);
  }

  // --- Language (Part M/P) ---

  Future<String> getLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_kLanguage) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await _prefs;
    await prefs.setString(_kLanguage, languageCode);
  }

  /// Dev/demo helper — wipes all stored preferences so you can replay the
  /// onboarding flow without reinstalling the app. Not called anywhere in
  /// production code paths.
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
