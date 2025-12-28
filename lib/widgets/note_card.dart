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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: note.colorHex != null 
            ? Color(int.parse('0xFF${note.colorHex!}')).withOpacity(0.1)
            : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
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
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  Text(
                    note.displayTitle,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isGrid ? 14 : 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      note.previewContent,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: isGrid ? 12 : 14,
                      ),
                      maxLines: isGrid ? 4 : 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 11,
                      color: AppTheme.subtextColor,
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
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: onPinPressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (onDeletePressed != null)
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: AppTheme.subtextColor,
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