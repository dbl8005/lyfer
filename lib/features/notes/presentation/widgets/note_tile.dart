import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/features/notes/models/note_model.dart';
import 'package:lyfer/features/notes/services/note_service.dart';

class NoteTile extends ConsumerWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.habitId,
    required this.onNoteDeleted, // Add this line
  });

  final String habitId;
  final NoteModel note;
  final VoidCallback onNoteDeleted; // Add this line

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: //TODO Make the color with opacity

          note.color != null ? Color(int.parse(note.color!, radix: 16)) : null,
      child: ListTile(
        title: Row(
          children: [
            Text(note.title),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd/MM/yyyy').format(note.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        subtitle: Text(
          note.text,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Handle delete action
            ConfirmDialog.show(
                context: context,
                content: 'Are you sure you want to delete this note?',
                onConfirm: () async {
                  // Make this async
                  await ref.read(noteServiceProvider).deleteNote(
                        habitId,
                        note.id,
                      );
                  onNoteDeleted(); // Call the callback after deletion
                });
          },
        ),
        onTap: () {
          context.push(
            '${AppRouterConsts.note}/${habitId}/${note.id}',
          );
        },
      ),
    );
  }
}
