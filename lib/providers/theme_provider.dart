import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService;
  ThemeMode _currentTheme = ThemeMode.system;

  ThemeProvider({ThemeService? themeService})
      : _themeService = themeService ?? ThemeService() {
    loadThemePreference();
  }

  // Getter
  ThemeMode get currentTheme => _currentTheme;

  /// Check if current theme is dark mode
  bool get isDarkMode {
    if (_currentTheme == ThemeMode.dark) {
      return true;
    } else if (_currentTheme == ThemeMode.light) {
      return false;
    } else {
      // System mode - check system brightness
      return getSystemTheme() == ThemeMode.dark;
    }
  }

  /// Load theme preference from local storage on app start
  Future<void> loadThemePreference() async {
    try {
      _currentTheme = await _themeService.getThemePreference();
      notifyListeners();
    } catch (e) {
      // If loading fails, default to system theme
      _currentTheme = ThemeMode.system;
      notifyListeners();
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    try {
      if (_currentTheme == ThemeMode.light) {
        _currentTheme = ThemeMode.dark;
      } else if (_currentTheme == ThemeMode.dark) {
        _currentTheme = ThemeMode.light;
      } else {
        // If system mode, toggle to opposite of current system theme
        final systemTheme = getSystemTheme();
        _currentTheme = systemTheme == ThemeMode.dark 
            ? ThemeMode.light 
            : ThemeMode.dark;
      }
      
      await _themeService.setThemePreference(_currentTheme);
      notifyListeners();
    } catch (e) {
      // If toggle fails, revert to previous theme
      notifyListeners();
    }
  }

  /// Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    try {
      _currentTheme = mode;
      await _themeService.setThemePreference(mode);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  /// Get system theme based on platform brightness
  ThemeMode getSystemTheme() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Get light theme configuration
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  /// Get dark theme configuration
  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }
}
