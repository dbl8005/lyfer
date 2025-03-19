import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/widgets/detail_widgets/habit_calendar_view.dart';
import 'package:lyfer/features/habits/presentation/widgets/detail_widgets/habit_header_card.dart';
import 'package:lyfer/features/habits/presentation/widgets/detail_widgets/habit_statistics.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';
import 'package:lyfer/features/notes/models/note_model.dart';
import 'package:lyfer/features/notes/presentation/widgets/notes_grid_view.dart';
import 'package:lyfer/features/notes/services/note_service.dart';

/// A screen that displays detailed information about a habit
/// including its metadata, calendar view, statistics, and related notes.
class HabitDetails extends ConsumerStatefulWidget {
  const HabitDetails({super.key, required this.habit});

  /// The habit model to display details for
  final HabitModel habit;

  @override
  ConsumerState<HabitDetails> createState() => _HabitDetailsState();
}

class _HabitDetailsState extends ConsumerState<HabitDetails> {
  /// List of notes associated with this habit
  List<NoteModel> notes = [];

  /// Loading state for notes
  bool isLoading = true;

  /// The currently focused day in the calendar
  DateTime _focusedDay = DateTime.now();

  /// The currently selected day in the calendar
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _selectedDay = _focusedDay;
  }

  /// Loads all notes associated with the current habit
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
    }
  }

  /// Prompts for confirmation and deletes the current habit
  Future<void> _deleteHabit() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Habit',
      content:
          'Are you sure you want to delete this habit? All associated notes will also be deleted.',
      confirmText: 'DELETE',
    );

    if (confirmed == true) {
      try {
        await ref.read(habitServiceProvider).deleteHabit(widget.habit.id!);
        if (mounted) {
          AppSnackbar.show(
            context: context,
            message: 'Habit deleted successfully',
            backgroundColor: Colors.green,
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.show(
            context: context,
            message: 'Failed to delete habit: $e',
            backgroundColor: Colors.red,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card with habit details
              HabitHeaderCard(habit: widget.habit),
              const SizedBox(height: 24),

              // Calendar view
              HabitCalendarView(
                habit: widget.habit,
              ),
              const SizedBox(height: 24),

              // Statistics section
              HabitStatistics(habit: widget.habit),
              const SizedBox(height: 24),

              // Notes section
              NotesGridView(
                habitId: widget.habit.id!,
                notes: notes,
                isLoading: isLoading,
                onNoteDeleted: _loadNotes,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the app bar with edit and delete actions
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Habit Details'),
      actions: [
        IconButton(
          icon: const Icon(LineIcons.pen),
          tooltip: 'Edit habit',
          onPressed: () => context.push(
              '${AppRouterConsts.habitEdit}/${widget.habit.id}',
              extra: widget.habit),
        ),
        IconButton(
          icon: const Icon(LineIcons.trash),
          tooltip: 'Delete habit',
          color: Colors.red,
          onPressed: _deleteHabit,
        ),
      ],
    );
  }

  /// Builds the floating action button for adding new notes
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => context.push(
        '${AppRouterConsts.newNote}/${widget.habit.id}',
        extra: widget.habit.id,
      ),
      tooltip: 'Add note',
      child: const Icon(Icons.note_add),
    );
  }
}
