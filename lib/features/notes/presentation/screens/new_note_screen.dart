import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/features/habits/presentation/widgets/habit_color_picker.dart';
import 'package:lyfer/features/notes/models/note_model.dart';
import 'package:lyfer/features/notes/services/note_service.dart';

class NewNoteScreen extends ConsumerStatefulWidget {
  const NewNoteScreen({super.key, required this.habitId});
  final String habitId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends ConsumerState<NewNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  Color? _selectedColor = Colors.yellow;

  Future<void> _saveNote() async {
    final note = NoteModel(
      title: _titleController.text,
      text: _textController.text,
      tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
      color: _selectedColor?.value
          .toRadixString(16)
          .padLeft(8, '0'), // Convert color to hex string
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(noteServiceProvider).createNote(
          widget.habitId,
          note,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _textController.text.isNotEmpty) {
                _saveNote();
              } else {
                AppSnackbar.show(
                  context: context,
                  message: 'Please fill in title and text.',
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Text'),
              maxLines: 5,
            ),
            TextField(
              controller: _tagsController,
              decoration:
                  const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            HabitColorPicker(
              selectedColor: _selectedColor,
              onColorChanged: (value) => setState(
                () {
                  _selectedColor = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
