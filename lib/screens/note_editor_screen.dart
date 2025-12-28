import 'package:flutter/material.dart';
import 'package:fast_note/models/note.dart';
import 'package:fast_note/services/hive_service.dart';
import 'package:fast_note/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isPinned;
  String? _selectedColorHex;
  bool _hasChanges = false;

  final List<Color> _colorOptions = [
    const Color(0xFFFFFFA0), // Light Yellow
    const Color(0xFFFCA590), // Salmon Pink
    const Color(0xFFCDEFF1), // Light Cyan
    const Color(0xFFFEC871), // Light Orange
    const Color(0xFFD8A7FF), // Light Purple
    const Color(0xFFA0E7FF), // Light Blue
    const Color(0xFFFFB6C1), // Light Pink
    const Color(0xFF98FB98), // Pale Green
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _isPinned = widget.note?.isPinned ?? false;
    _selectedColorHex = widget.note?.colorHex;
    
    _titleController.addListener(_checkChanges);
    _contentController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final hasContentChanges = 
      _titleController.text != widget.note?.title ||
      _contentController.text != widget.note?.content ||
      _isPinned != widget.note?.isPinned ||
      _selectedColorHex != widget.note?.colorHex;
    
    if (hasContentChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasContentChanges;
      });
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty && 
        _contentController.text.trim().isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    if (widget.note == null) {
      final newNote = Note(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        colorHex: _selectedColorHex,
        isPinned: _isPinned,
      );
      await HiveService.addNote(newNote);
    } else {
      widget.note!.title = _titleController.text.trim();
      widget.note!.content = _contentController.text.trim();
      widget.note!.isPinned = _isPinned;
      widget.note!.colorHex = _selectedColorHex;
      await widget.note!.save();
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () async {
            if (_hasChanges) {
              final shouldSave = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: theme.colorScheme.surface,
                  title: Text('Save Changes?', style: theme.textTheme.bodyLarge),
                  content: Text('Do you want to save your changes?', style: theme.textTheme.bodyMedium),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Discard'),
                    ),
                    TextButton(
                      onPressed: () {
                        _saveNote();
                        Navigator.pop(context, true);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (shouldSave == true) return;
            }
            Navigator.pop(context, false);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Iconsax.bookmark: Iconsax.bookmark_2),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
                _checkChanges();
              });
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.tick_circle),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: theme.textTheme.displayMedium,
              decoration: InputDecoration(
                hintText: 'Title (optional)',
                hintStyle: theme.textTheme.displayMedium!.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                border: InputBorder.none,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Start typing...',
                  hintStyle: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colorOptions.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorHex = null;
                          _checkChanges();
                        });
                      },
                      child: Container(
                        width: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedColorHex == null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withOpacity(0.3),
                            width: _selectedColorHex == null ? 2 : 1,
                          ),
                        ),
                        child: Icon(Iconsax.color_swatch, color: theme.colorScheme.primary),
                      ),
                    );
                  }
                  
                  final color = _colorOptions[index - 1];
                  final colorHex = color.value.toRadixString(16).substring(2);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorHex = colorHex;
                        _checkChanges();
                      });
                    },
                    child: Container(
                      width: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedColorHex == colorHex
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: _selectedColorHex == colorHex ? 2 : 0,
                        ),
                        boxShadow: _selectedColorHex == colorHex
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.color_swatch,
                          color: _getTextColor(color),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}