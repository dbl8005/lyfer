import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/features/notes/models/note_model.dart';

/// Displays a single note card with title, content, and actions
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.habitId,
    required this.onDelete,
  });

  /// The note model to display
  final NoteModel note;

  /// The ID of the habit this note belongs to
  final String habitId;

  /// Callback when delete action is triggered
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Parse the color string to a Color object
    final noteColor = _parseNoteColor();

    return Card(
      color: noteColor.withOpacity(0.7),
      child: InkWell(
        onTap: () => context.push(
          '${AppRouterConsts.note}/$habitId/${note.id}',
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Divider(),
              Expanded(
                child: Text(
                  note.text,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (note.tags.isNotEmpty) _buildTagsRow(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header row with title and delete button
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            note.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: onDelete,
          child: const Icon(Icons.close, size: 18),
        ),
      ],
    );
  }

  /// Builds the tags row showing all tags
  Widget _buildTagsRow() {
    return Row(
      children: [
        const Icon(LineIcons.tag, size: 12),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            note.tags.join(', '),
            style: TextStyle(
              fontSize: 10,
              color: Colors.black.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Parses the color string from the note model
  Color _parseNoteColor() {
    Color noteColor = Colors.grey.shade200;
    if (note.color != null) {
      try {
        noteColor = Color(int.parse(note.color!, radix: 16));
      } catch (e) {
        // Use default color if parsing fails
      }
    }
    return noteColor;
  }
}
