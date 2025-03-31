import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/features/notes/models/note_model.dart';
import 'package:lyfer/features/notes/presentation/widgets/note_card.dart';
import 'package:lyfer/features/notes/services/note_service.dart';

/// Displays a grid view of notes with proper loading and empty states
class NotesGridView extends ConsumerWidget {
  const NotesGridView({
    super.key,
    required this.habitId,
    required this.notes,
    required this.isLoading,
    required this.onNoteDeleted,
  });

  /// The ID of the habit the notes belong to
  final String habitId;

  /// List of notes to display
  final List<NoteModel> notes;

  /// Whether the notes are currently loading
  final bool isLoading;

  /// Callback when a note is deleted
  final VoidCallback onNoteDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildNotesContent(context, ref),
      ],
    );
  }

  /// Builds the header section with title and count
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Notes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(width: 8),
        Text(
          '(${notes.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  /// Builds the main content area (loading, empty, or grid)
  Widget _buildNotesContent(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notes.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteCard(
          note: notes[index],
          habitId: habitId,
          onDelete: () async {
            final confirmed = await ConfirmDialog.show(
              context: context,
              content: 'Are you sure you want to delete this note?',
            );
            if (confirmed == true) {
              await ref.read(noteServiceProvider).deleteNote(
                    habitId,
                    notes[index].id,
                  );
              onNoteDeleted();
            }
          },
        );
      },
    );
  }

  /// Builds the empty state when there are no notes
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(
            LineIcons.stickyNote,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a note',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
