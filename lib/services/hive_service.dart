import 'package:fast_note/models/note_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fast_note/models/note.dart';

class HiveService {
  static const String _boxName = 'notes_box';
  static Box<Note>? _notesBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }
    
    _notesBox = await Hive.openBox<Note>(_boxName);
  }

  static Box<Note> get _box {
    if (_notesBox == null || !_notesBox!.isOpen) {
      throw Exception('Hive not initialized. Call init() first.');
    }
    return _notesBox!;
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