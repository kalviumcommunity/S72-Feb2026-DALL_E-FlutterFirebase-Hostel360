import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences? _prefs;

  ThemeService({SharedPreferences? prefs}) : _prefs = prefs;

  /// Get theme preference from local storage
  /// Returns ThemeMode.system if no preference is stored
  Future<ThemeMode> getThemePreference() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);
      
      if (themeModeString == null) {
        return ThemeMode.system;
      }
      
      switch (themeModeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      return ThemeMode.system;
    }
  }

  /// Save theme preference to local storage
  Future<bool> setThemePreference(ThemeMode mode) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      String themeModeString;
      
      switch (mode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }
      
      return await prefs.setString(_themeKey, themeModeString);
    } catch (e) {
      return false;
    }
  }
}
