import 'package:fast_note/enums/sort_enums.dart';
import 'package:fast_note/providers/settings_provider.dart';
import 'package:fast_note/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fast_note/models/note.dart';
import 'package:fast_note/services/hive_service.dart';
import 'package:fast_note/widgets/note_card.dart';
import 'package:fast_note/screens/note_editor_screen.dart';
import 'package:fast_note/providers/theme_provider.dart';
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
  SortOption currentSortOption = SortOption.dateUpdated;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    isGridView = settingsProvider.settings.defaultGridView;
    currentSortOption = settingsProvider.settings.defaultSortOption;
    
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    notes = HiveService.getAllNotes();
    _sortNotes();
    _filterNotes();
  }


  void _sortNotes() {
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      switch (currentSortOption) {
        case SortOption.dateUpdated:
          return b.updatedAt.compareTo(a.updatedAt);
        case SortOption.dateCreated:
          return b.createdAt.compareTo(a.createdAt);
        case SortOption.title:
          return a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase());
      }
    });
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Delete Note', style: Theme.of(context).textTheme.bodyLarge),
        content: Text('Are you sure you want to delete this note?', 
          style: Theme.of(context).textTheme.bodyMedium),
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
                SnackBar(
                  content: const Text('Note deleted'),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sort By',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1,
            ),
            ...SortOption.values.map((option) {
              final isSelected = currentSortOption == option;
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ) : null,
                ),
                title: Text(
                  _getSortOptionName(option),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected 
                  ? Icon(
                      Iconsax.tick_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    )
                  : null,
                onTap: () {
                  setState(() {
                    currentSortOption = option;
                    _sortNotes();
                    _filterNotes();
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  String _getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.dateUpdated:
        return 'Last Updated';
      case SortOption.dateCreated:
        return 'Date Created';
      case SortOption.title:
        return 'Title (A-Z)';
    }
  }

  void _showMenuOptions() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Iconsax.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Add Note',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 300));
                _openNoteEditor(null);
              },
            ),
            ListTile(
              leading: Icon(
                Iconsax.setting_2,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () async {
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 300));
                _openSettings();
              },
            ),
            ListTile(
              leading: Icon(
                Iconsax.info_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'About',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('About Fast Note', style: Theme.of(context).textTheme.bodyLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'A beautiful note-taking app with customizable colors and themes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Modern Notes', style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        )),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Iconsax.sun_1 : Iconsax.moon,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                  final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                  final settings = settingsProvider.settings;
                  settings.themeMode = themeProvider.isDarkMode ? 'dark' : 'light';
                  settingsProvider.updateSettings(settings);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.menu_1),
            onPressed: _showMenuOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSearchFocused 
                          ? theme.colorScheme.primary
                          : Colors.grey,
                        width: _isSearchFocused ? 2 : 1,
                      ),
                      boxShadow: _isSearchFocused
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          Iconsax.search_normal_1, 
                          size: 20, 
                          color: _isSearchFocused
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (value) {
                              searchQuery = value;
                              _filterNotes();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search notes...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              isCollapsed: true,
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Iconsax.close_circle, 
                              size: 20, 
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              searchQuery = '';
                              _filterNotes();
                            },
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isGridView ? Iconsax.note_1 : Iconsax.grid_1,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: _toggleView,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Iconsax.sort,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: _showSortOptions,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'No notes yet\nTap + to create one'
                              : 'No notes found',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 42),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(null),
        backgroundColor: theme.colorScheme.primary,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Iconsax.book, color: Theme.of(context).colorScheme.primary),
              title: Text(note.isPinned ? 'Unpin Note' : 'Pin Note',
                style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                _togglePin(note);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Iconsax.copy, color: Theme.of(context).colorScheme.primary),
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
                  SnackBar(
                    content: const Text('Note duplicated'),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
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
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}