import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/habits/presentation/widgets/habit_color_picker.dart';
import 'package:lyfer/features/notes/models/note_model.dart';
import 'package:lyfer/features/notes/services/note_service.dart';

class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({
    super.key,
    required this.habitId,
    required this.note,
  });

  final String habitId;
  final NoteModel? note;

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  Color? _selectedColor = Colors.yellow;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _textController.text = widget.note!.text;
      _tagsController.text = widget.note!.tags.join(', ');
      if (widget.note!.color != null) {
        _selectedColor = Color(int.parse(widget.note!.color!, radix: 16));
      }
    }

    // Add listeners for auto-save
    _titleController.addListener(_autoSave);
    _textController.addListener(_autoSave);
    _tagsController.addListener(_autoSave);
  }

  void _autoSave() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final note = NoteModel(
        id: widget.note!.id,
        title: _titleController.text,
        text: _textController.text,
        tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        color: _selectedColor?.value.toRadixString(16).padLeft(8, '0'),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.note == null) {
        // Create new note
        await ref.read(noteServiceProvider).createNote(widget.habitId, note);
      } else {
        // Update existing note
        await ref.read(noteServiceProvider).updateNote(widget.habitId, note);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _textController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : '${widget.note!.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Text'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration:
                  const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            const SizedBox(height: 16),
            HabitColorPicker(
              selectedColor: _selectedColor,
              onColorChanged: (value) {
                setState(() {
                  _selectedColor = value;
                });
                _autoSave();
              },
            ),
          ],
        ),
      ),
    );
  }
}
