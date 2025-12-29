import 'package:fast_note/enums/sort_enums.dart';
import 'package:flutter/material.dart';
import 'package:fast_note/models/settings.dart';
import 'package:fast_note/services/hive_service.dart';
import 'package:flutter/services.dart';

class SettingsProvider extends ChangeNotifier {
  Settings _settings = Settings();
  
  Settings get settings => _settings;
  
  SettingsProvider() {
    _loadSettings();
  }
  
Future<void> _loadSettings() async {
  _settings = HiveService.getSettings();
  
  if (_settings.openWithSearchBar == null) {
    _settings.openWithSearchBar = false;
    await updateSettings(_settings);
  }
  
  await _applyFullScreenMode();
  notifyListeners();
}
  
  Future<void> updateSettings(Settings newSettings) async {
    _settings = newSettings;
    await HiveService.saveSettings(_settings);
    await _applyFullScreenMode();
    notifyListeners();
  }
  
  Future<void> updateDefaultGridView(bool value) async {
    _settings.defaultGridView = value;
    await updateSettings(_settings);
  }
  
  Future<void> updateDefaultSortOption(SortOption option) async {
    _settings.defaultSortOption = option;
    await updateSettings(_settings);
  }
  
  Future<void> _applyFullScreenMode() async {
    if (_settings.enableFullScreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  Future<void> toggleRichLinks(bool value) async {
    _settings.displayRichLinks = value;
    await updateSettings(_settings);
  }
  
  Future<void> toggleAddToBottom(bool value) async {
    _settings.addItemToBottom = value;
    await updateSettings(_settings);
  }
  
  Future<void> changeThemeMode(String themeMode) async {
    _settings.themeMode = themeMode;
    await updateSettings(_settings);
  }
  
  Future<void> toggleSharing(bool value) async {
    _settings.enableSharing = value;
    await updateSettings(_settings);
  }
  
  Future<void> toggleFullScreen(bool value) async {
    _settings.enableFullScreen = value;
    await updateSettings(_settings);
  }

  Future<void> toggleOpenWithSearchBar(bool value) async {
    _settings.openWithSearchBar = value;
    await updateSettings(_settings);
  }
}