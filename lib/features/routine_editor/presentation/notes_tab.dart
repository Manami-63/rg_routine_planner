import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routines/presentation/routine_controller.dart';

/// Free-text notes of a routine, e.g. music or choreography reminders.
/// Saved while typing, like the other changes on the routine page.
class NotesTab extends ConsumerStatefulWidget {
  const NotesTab({super.key, required this.routineId});

  final String routineId;

  @override
  ConsumerState<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<NotesTab> {
  // Only this tab edits the notes, so the text is read once rather than
  // watched (watching would reset the cursor on every keystroke).
  late final _notes = TextEditingController(
    text: ref.read(routineProvider(widget.routineId)).notes,
  );

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      TextField(
        key: const ValueKey('routine-notes'),
        controller: _notes,
        minLines: 8,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Notes',
          hintText: 'Music, choreography, reminders from your coach...',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
        onChanged: ref
            .read(routineControllerProvider(widget.routineId).notifier)
            .updateNotes,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    ],
  );
}
