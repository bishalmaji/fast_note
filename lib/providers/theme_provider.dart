import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fast_note/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  final String _themeBox = 'theme_preferences';
  final String _themeKey = 'isDarkMode';
  
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final box = await Hive.openBox(_themeBox);
    _isDarkMode = box.get(_themeKey, defaultValue: false) as bool;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final box = await Hive.openBox(_themeBox);
    await box.put(_themeKey, _isDarkMode);
    notifyListeners();
  }
}