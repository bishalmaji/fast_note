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
    AppTheme.primaryColor,
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEC4899), // Pink
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () async {
            if (_hasChanges) {
              final shouldSave = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Save Changes?'),
                  content: const Text('Do you want to save your changes?'),
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
            icon: Icon(_isPinned ? Iconsax.paintbucket : Iconsax.paintbucket1),
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
              style: Theme.of(context).textTheme.displayMedium,
              decoration: InputDecoration(
                hintText: 'Title (optional)',
                hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppTheme.subtextColor,
                ),
                border: InputBorder.none,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Start typing...',
                  hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: AppTheme.subtextColor,
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
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedColorHex == null
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                            width: _selectedColorHex == null ? 2 : 1,
                          ),
                        ),
                        child: const Icon(Iconsax.color_swatch),
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
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedColorHex == colorHex
                              ? color
                              : Colors.transparent,
                          width: _selectedColorHex == colorHex ? 2 : 0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.color_swatch,
                          color: color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}