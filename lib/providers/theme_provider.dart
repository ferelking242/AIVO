import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _darkModeKey = 'dark_mode_enabled';

  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  ThemeType _themeType = ThemeType.light;

  bool get isDarkMode => _isDarkMode;
  ThemeType get themeType => _themeType;

  ThemeProvider() {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
    final themeIndex = _prefs.getInt(_themeKey) ?? ThemeType.light.index;
    _themeType = ThemeType.values[themeIndex];
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(ThemeType theme) async {
    _themeType = theme;
    await _prefs.setInt(_themeKey, theme.index);
    notifyListeners();
  }

  ThemeData getTheme() {
    if (_isDarkMode) {
      return getDarkTheme(_themeType);
    } else {
      return getLightTheme(_themeType);
    }
  }

  static ThemeData getLightTheme(ThemeType themeType) {
    late Color primaryColor;

    switch (themeType) {
      case ThemeType.light:
        primaryColor = const Color(0xFF1F77F3); // Classic Blue
        break;
      case ThemeType.marine:
        primaryColor = const Color(0xFF0A3B8D); // Navy Marine
        break;
      case ThemeType.skyBlue:
        primaryColor = const Color(0xFF00A8E8); // Sky Blue
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: const Color(0xFFFFA500),
        surface: const Color(0xFFF5F5F5),
        error: const Color(0xFFE74C3C),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Colors.black45,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFFF5F5F5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.black45),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  static ThemeData getDarkTheme(ThemeType themeType) {
    late Color primaryColor;

    switch (themeType) {
      case ThemeType.light:
        primaryColor = const Color(0xFF1F77F3); // Classic Blue
        break;
      case ThemeType.marine:
        primaryColor = const Color(0xFF0A3B8D); // Navy Marine (lighter for dark mode)
        break;
      case ThemeType.skyBlue:
        primaryColor = const Color(0xFF00A8E8); // Sky Blue
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF1a1a1a),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF2d2d2d),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: const Color(0xFFFFA500),
        surface: const Color(0xFF2d2d2d),
        error: const Color(0xFFE74C3C),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF2d2d2d),
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFF3d3d3d),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.white60),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

enum ThemeType {
  light,
  marine,
  skyBlue,
}

extension ThemeTypeName on ThemeType {
  String get displayName {
    switch (this) {
      case ThemeType.light:
        return 'Classic Blue';
      case ThemeType.marine:
        return 'Marine Navy';
      case ThemeType.skyBlue:
        return 'Sky Blue';
    }
  }
}
