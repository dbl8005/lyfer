import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/notes/models/note_model.dart';
import 'package:lyfer/features/notes/presentation/widgets/note_tile.dart';
import 'package:lyfer/features/notes/services/note_service.dart';

class HabitDetails extends ConsumerStatefulWidget {
  const HabitDetails({super.key, required this.habit});
  final HabitModel habit;

  @override
  ConsumerState<HabitDetails> createState() => _HabitDetailsState();
}

class _HabitDetailsState extends ConsumerState<HabitDetails> {
  List<NoteModel> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final fetchedNotes =
          await ref.read(noteServiceProvider).getNotes(widget.habit.id!);
      setState(() {
        notes = fetchedNotes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit icon and name
            Row(
              children: [
                // Placeholder for habit icon
                widget.habit.icon != null
                    ? LineIcon(
                        HabitIcon.values
                            .firstWhere((e) => e.name == widget.habit.icon)
                            .icon,
                        size: 40,
                      )
                    : const Icon(
                        Icons.check_circle_outline,
                        size: 40,
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${widget.habit.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Habit details
            Text(
              '${widget.habit.description}',
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Habit frequency
            Text(
              'Frequency: ${widget.habit.frequency.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // Habit Streak
            Text(
              'Current Streak: ${widget.habit.streakCount}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // Habit Notes
            Row(
              children: [
                Text(
                  'Notes:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const LineIcon.plusSquare(),
                  onPressed: () {
                    context.push(
                      '${AppRouterConsts.newNote}/${widget.habit.id}',
                      extra: widget.habit.id,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Notes list
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                    ? const Text('No notes available.')
                    : Expanded(
                        child: ListView.builder(
                          // TODO Sort the notes by date updated
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return NoteTile(
                              note: note,
                              habitId: widget.habit.id!,
                              onNoteDeleted: () {
                                _loadNotes(); // Reload notes after deletion
                              },
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
