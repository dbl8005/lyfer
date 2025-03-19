import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/enums/habit_enums.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:lyfer/core/config/enums/icon_enum.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';
import 'package:lyfer/features/habits/services/habit_service.dart';
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _selectedDay = _focusedDay;
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
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.pen),
            tooltip: 'Edit habit',
            onPressed: () {
              context.push('${AppRouterConsts.habitEdit}/${widget.habit.id}',
                  extra: widget.habit);
            },
          ),
          IconButton(
            icon: const Icon(LineIcons.trash),
            tooltip: 'Delete habit',
            color: Colors.red,
            onPressed: _deleteHabit,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(
            '${AppRouterConsts.newNote}/${widget.habit.id}',
            extra: widget.habit.id,
          );
        },
        child: const Icon(Icons.note_add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card with habit details
              _buildHeaderCard(context),
              const SizedBox(height: 24),

              // Calendar view
              _buildCalendarView(context),
              const SizedBox(height: 24),

              // Statistics section
              _buildStatisticsSection(context),
              const SizedBox(height: 24),

              // Notes section
              _buildNotesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.habit.color ??
                        widget.habit.category.defaultColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.habit.category.icon,
                    size: 40,
                    color: widget.habit.color ??
                        widget.habit.category.defaultColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      if (widget.habit.priority.name != 'none')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.habit.priority
                                .getColor(context)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.habit.priority.icon,
                                size: 16,
                                color: widget.habit.priority.getColor(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.habit.priority.label,
                                style: TextStyle(
                                  color:
                                      widget.habit.priority.getColor(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.habit.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                widget.habit.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 16),
            _buildInfoRow(context, LineIcons.calendar, 'Frequency',
                '${_formatEnumName(widget.habit.frequency.name)} ${widget.habit.frequency != Frequency.daily ? '(${widget.habit.timesPerPeriod} times per ${widget.habit.periodLabel})' : ''}'),
            const SizedBox(height: 8),
            _buildInfoRow(context, LineIcons.clock, 'Preferred Time',
                widget.habit.preferredTime.label),
            if (widget.habit.selectedDays.isNotEmpty &&
                widget.habit.selectedDays.length < 7) ...[
              const SizedBox(height: 8),
              _buildInfoRow(context, LineIcons.calendarCheck, 'Selected Days',
                  _getWeekdaysText(widget.habit.selectedDays)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Completion Calendar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              // onDaySelected: (selectedDay, focusedDay) {
              //   setState(() {
              //     _selectedDay = selectedDay;
              //     _focusedDay = focusedDay;
              //   });
              // },
              calendarStyle: CalendarStyle(
                markersMaxCount: 50,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // Check if the habit was completed on this day
                  final isCompleted = widget.habit.completedDates
                      .any((date) => isSameDay(date, day));

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.green.withOpacity(0.3) : null,
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          color: isCompleted ? Colors.green.shade800 : null,
                          fontWeight: isCompleted ? FontWeight.bold : null,
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

  Widget _buildStatisticsSection(BuildContext context) {
    final currentStreak = widget.habit.streakCount;
    final completionsThisPeriod = widget.habit.getCompletionsInCurrentPeriod();
    final progress = completionsThisPeriod / widget.habit.timesPerPeriod;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  context: context,
                  title: 'Current Streak',
                  value: '$currentStreak',
                  icon: LineIcons.fire,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  context: context,
                  title: 'Completion',
                  value: '${(progress * 100).toInt()}%',
                  icon: LineIcons.checkCircle,
                  color: Colors.green,
                ),
                _buildStatCard(
                  context: context,
                  title: 'This ${widget.habit.periodLabel}',
                  value:
                      '$completionsThisPeriod/${widget.habit.timesPerPeriod}',
                  icon: LineIcons.calendarCheck,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            Text(
              '(${notes.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : notes.isEmpty
                ? Center(
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
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a note',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return _buildNoteCard(notes[index]);
                    },
                  ),
      ],
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    // Parse the color string to a Color object
    Color noteColor = Colors.grey.shade200;
    if (note.color != null) {
      try {
        noteColor = Color(int.parse(note.color!, radix: 16));
      } catch (e) {
        // Use default color if parsing fails
      }
    }

    return Card(
      color: noteColor.withOpacity(0.7),
      child: InkWell(
        onTap: () {
          context.push(
            '${AppRouterConsts.note}/${widget.habit.id}/${note.id}',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    onTap: () async {
                      final confirmed = await ConfirmDialog.show(
                        context: context,
                        content: 'Are you sure you want to delete this note?',
                      );
                      if (confirmed == true) {
                        await ref.read(noteServiceProvider).deleteNote(
                              widget.habit.id!,
                              note.id,
                            );
                        _loadNotes();
                      }
                    },
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Text(
                  note.text,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatEnumName(String name) {
    return name
        .split('.')
        .last
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _getWeekdaysText(Set<int> days) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days.map((day) => weekdays[day]).join(', ');
  }
}
