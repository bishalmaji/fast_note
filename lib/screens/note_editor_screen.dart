import 'package:flutter/material.dart';
import 'package:fast_note/models/note.dart';
import 'package:fast_note/services/hive_service.dart';
import 'package:flutter/services.dart';
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
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  bool _isShiftPressed = false;

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
  
  _titleFocusNode = FocusNode();
  _contentFocusNode = FocusNode();
  
  _titleFocusNode.addListener(() {
    setState(() {}); 
  });
  
  _contentFocusNode.addListener(() {
    setState(() {}); 
  });
  
  _titleController.addListener(_checkChanges);
  _contentController.addListener(_checkChanges);
  
 
  HardwareKeyboard.instance.addHandler(_handleKeyEvent);
 
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _contentFocusNode.requestFocus();
  });
}
  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft || 
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        setState(() {
          _isShiftPressed = true;
        });
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft || 
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        setState(() {
          _isShiftPressed = false;
        });
      }
    }
    return false;
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
    final backgroundColor = _selectedColorHex != null 
        ? Color(int.parse('FF$_selectedColorHex', radix: 16))
        : theme.colorScheme.background;
    
    return Scaffold(
      backgroundColor: backgroundColor,
    appBar: PreferredSize(
  preferredSize: const Size.fromHeight(48),
  child: SafeArea(
    bottom: false,
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        
          _toolbarButton(
            icon: Iconsax.arrow_left_2,
            onTap: () async {
   
              if (_hasChanges) {
                final shouldSave = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text('Save Changes?', style: theme.textTheme.titleMedium),
                    content: Text('Do you want to save your changes?', style: theme.textTheme.bodyMedium),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                        child: const Text('Discard'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _saveNote();
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
                if (shouldSave == true) return;
              }
              Navigator.pop(context, false);
            
            },
            theme: theme,
          ),

          const Spacer(),

        
          _toolbarButton(
            icon: _isPinned
                ? Icons.push_pin_rounded
                : Icons.push_pin_outlined,
            color: _isPinned ? Colors.amber : theme.colorScheme.onSurface,
            onTap: () {
              setState(() => _isPinned = !_isPinned);
              _checkChanges();
            },
            theme: theme,
          ),

          const SizedBox(width: 8),

        
          _toolbarButton(
            icon: Iconsax.tick_circle,
            color: theme.colorScheme.primary,
            onTap: _saveNote,
            theme: theme,
          ),
        ],
      ),
    ),
  ),
),


 body: Container(
        margin: EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
Container(
  margin: const EdgeInsets.only(bottom: 16),
  decoration: BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: _titleFocusNode.hasFocus
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withOpacity(0.2),
      width: _titleFocusNode.hasFocus ? 2 : 1,
    ),
    boxShadow: _titleFocusNode.hasFocus
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
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: TextField(
      controller: _titleController,
      focusNode: _titleFocusNode,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
      decoration: InputDecoration(
        hintText: 'Title',
        hintStyle: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          fontWeight: FontWeight.w400,
          fontSize: 22,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: 2,
      textInputAction: TextInputAction.done,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          _saveNote();
        }
      },
    ),
  ),
),

Expanded(
  child: Container(
    constraints: const BoxConstraints(minHeight: 200),

     decoration: BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: _contentFocusNode.hasFocus
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withOpacity(0.2),
      width: _contentFocusNode.hasFocus ? 2 : 1,
    ),
    boxShadow: _contentFocusNode.hasFocus
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
 child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _contentController,
        focusNode: _contentFocusNode,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText: 'Start typing your note...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 16,
            height: 1.6,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        onSubmitted: (value) {
          if (!_isShiftPressed && _contentController.text.trim().isNotEmpty) {
            _titleFocusNode.requestFocus();
          }
        },
      ),
    ),
  ),
),
            const SizedBox(height: 20),
            Text(
              'Note Color',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colorOptions.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildColorOption(
                      color: theme.colorScheme.surface,
                      isSelected: _selectedColorHex == null,
                      isDefault: true,
                      theme: theme,
                    );
                  }
                  
                  final color = _colorOptions[index - 1];
                  final colorHex = color.value.toRadixString(16).substring(2);
                  
                  return _buildColorOption(
                    color: color,
                    isSelected: _selectedColorHex == colorHex,
                    theme: theme,
                    onTap: () {
                      setState(() {
                        _selectedColorHex = colorHex;
                        _checkChanges();
                      });
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption({
    required Color color,
    required bool isSelected,
    required ThemeData theme,
    bool isDefault = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {
        setState(() {
          _selectedColorHex = null;
          _checkChanges();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isDefault
              ? Icon(
                  Iconsax.color_swatch,
                  color: theme.colorScheme.primary,
                  size: 24,
                )
              : Icon(
                  Iconsax.color_swatch,
                  color: _getTextColor(color),
                  size: 24,
                ),
        ),
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  Widget _toolbarButton({
  required IconData icon,
  required VoidCallback onTap,
  required ThemeData theme,
  Color? color,
}) {
  return SizedBox(
    width: 48,
    height: 48,
    child: Material(
      color: theme.colorScheme.surface.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ),
    ),
  );
}


  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }
}