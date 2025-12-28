import 'package:flutter/material.dart';
import 'package:fast_note/models/note.dart';
import 'package:fast_note/services/hive_service.dart';
import 'package:fast_note/widgets/note_card.dart';
import 'package:fast_note/screens/note_editor_screen.dart';
import 'package:fast_note/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  bool isGridView = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    notes = HiveService.getAllNotes();
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    _filterNotes();
  }

  void _filterNotes() {
    if (searchQuery.isEmpty) {
      filteredNotes = List.from(notes);
    } else {
      filteredNotes = notes.where((note) {
        return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            note.content.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  void _toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  void _togglePin(Note note) {
    note.isPinned = !note.isPinned;
    note.save();
    _loadNotes();
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HiveService.deleteNote(note.id);
              _loadNotes();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Modern Notes'),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Iconsax.note_1 : Iconsax.grid_1),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                searchQuery = value;
                _filterNotes();
              },
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Iconsax.search_normal_1),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          _searchController.clear();
                          searchQuery = '';
                          _filterNotes();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isEmpty
                              ? Iconsax.note_remove
                              : Iconsax.search_normal,
                          size: 64,
                          color: AppTheme.subtextColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'No notes yet\nTap + to create one'
                              : 'No notes found',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          return NoteCard(
                            note: note,
                            isGrid: true,
                            onTap: () => _openNoteEditor(note),
                            onPinPressed: () => _togglePin(note),
                            onDeletePressed: () => _showNoteOptions(note),
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredNotes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          return SizedBox(
                            height: 120,
                            child: NoteCard(
                              note: note,
                              isGrid: false,
                              onTap: () => _openNoteEditor(note),
                              onPinPressed: () => _togglePin(note),
                              onDeletePressed: () => _showNoteOptions(note),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(null),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Iconsax.add),
      ),
    );
  }

  void _openNoteEditor(Note? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
    
    if (result == true) {
      _loadNotes();
    }
  }

  void _showNoteOptions(Note note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.paintbucket),
              title: Text(note.isPinned ? 'Unpin Note' : 'Pin Note'),
              onTap: () {
                _togglePin(note);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.copy),
              title: const Text('Duplicate'),
              onTap: () {
                final duplicatedNote = Note(
                  title: '${note.title} (Copy)',
                  content: note.content,
                  colorHex: note.colorHex,
                );
                HiveService.addNote(duplicatedNote);
                _loadNotes();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note duplicated')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteNote(note);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}