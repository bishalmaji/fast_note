import 'package:flutter/material.dart';
import 'package:fast_note/models/note.dart';
import 'package:fast_note/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback? onPinPressed;
  final VoidCallback? onDeletePressed;

  const NoteCard({
    super.key,
    required this.note,
    required this.isGrid,
    required this.onTap,
    this.onPinPressed,
    this.onDeletePressed,
  });

  Color _getNoteColor(BuildContext context) {
    if (note.colorHex != null) {
      return Color(int.parse('0xFF${note.colorHex!}'));
    }
    return Theme.of(context).colorScheme.surface;
  }

  Color _getTextColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final noteColor = _getNoteColor(context);
    final textColor = _getTextColor(noteColor);
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Icon(
                        Icons.push_pin_rounded,
                        size: 16,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  Text(
                    note.displayTitle,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isGrid ? 14 : 16,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      note.previewContent,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: isGrid ? 12 : 14,
                        color: textColor.withOpacity(0.8),
                      ),
                      maxLines: isGrid ? 4 : 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(note.updatedAt),
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 11,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (onPinPressed != null || onDeletePressed != null)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    if (onPinPressed != null)
                      IconButton(
                        icon: Icon(
                          note.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          size: 18,
                          color: textColor,
                        ),
                        onPressed: onPinPressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (onDeletePressed != null)
                      IconButton(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: textColor,
                        ),
                        onPressed: onDeletePressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}