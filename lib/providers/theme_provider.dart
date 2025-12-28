import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fast_note/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  final String _themeBox = 'theme_preferences';
  final String _themeKey = 'themeMode';
  
  String _themeMode = 'light';
  
  String get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == 'system') {
      return false; 
    }
    return _themeMode == 'dark';
  }
  
  ThemeData get currentTheme => _themeMode == 'dark' ? AppTheme.darkTheme : AppTheme.lightTheme;
  
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final box = await Hive.openBox(_themeBox);
    _themeMode = box.get(_themeKey, defaultValue: 'light') as String;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == 'light') {
      _themeMode = 'dark';
    } else if (_themeMode == 'dark') {
      _themeMode = 'light';
    } else {
      _themeMode = 'light';
    }
    
    final box = await Hive.openBox(_themeBox);
    await box.put(_themeKey, _themeMode);
    notifyListeners();
  }
  
  Future<void> setThemeMode(String themeMode) async {
    _themeMode = themeMode;
    final box = await Hive.openBox(_themeBox);
    await box.put(_themeKey, _themeMode);
    notifyListeners();
  }
}