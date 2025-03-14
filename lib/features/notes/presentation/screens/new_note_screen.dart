import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/core/widgets/circular_pi.dart';
import 'package:lyfer/features/habits/presentation/widgets/form/habit_color_picker.dart';
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
  Color? _selectedColor = Colors.grey;
  bool _isLoading = false;

  Future<void> _saveNote() async {
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          _isLoading
              ? CircularPI()
              : IconButton(
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
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Write your note here...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(), // Add a visible border
                  contentPadding:
                      EdgeInsets.all(16), // Add padding inside the field
                ),
                maxLines: null,
                expands: true,
                textAlignVertical:
                    TextAlignVertical.top, // This is the key property
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration:
                  const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            const SizedBox(height: 8),
            HabitColorPicker(
              selectedColor: _selectedColor,
              onColorChanged: (value) => setState(
                () {
                  _selectedColor = value;
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
