import 'package:fast_note/models/note_adapter.dart';
import 'package:fast_note/models/settings.dart';
import 'package:fast_note/models/settings_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fast_note/models/note.dart';

class HiveService {
  static const String _boxName = 'notes_box';
  static const String _settingsBoxName = 'settings_box';
  static Box<Note>? _notesBox;
  static Box<Settings>? _settingsBox;
  
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SettingsAdapter());
    }
    
    _notesBox = await Hive.openBox<Note>(_boxName);
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);

    if (_settingsBox!.isEmpty) {
      await _settingsBox!.put('settings', Settings());
    }
    
    _isInitialized = true;
  }

  static Box<Note> get _box {
    if (_notesBox == null || !_notesBox!.isOpen) {
      throw Exception('Hive not initialized. Call init() first.');
    }
    return _notesBox!;
  }

  static Box<Settings> get _settings {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Hive not initialized. Call init() first.');
    }
    return _settingsBox!;
  }

  
  static Settings getSettings() {
    return _settings.get('settings') ?? Settings();
  }

  static Future<void> saveSettings(Settings settings) async {
    await _settings.put('settings', settings);
  }

  static Future<void> addNote(Note note) async {
    await _box.put(note.id, note);
  }

  static Future<void> updateNote(Note note) async {
    await note.save();
  }

  static Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  static List<Note> getAllNotes() {
    return _box.values.toList();
  }

  static List<Note> searchNotes(String query) {
    if (query.isEmpty) return getAllNotes();
    
    return _box.values.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
             note.content.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}