import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routines/presentation/routine_controller.dart';

/// Edits the routine name. Stateful because a [TextEditingController] must
/// live as long as the field and be disposed with it.
class RoutineNameField extends ConsumerStatefulWidget {
  const RoutineNameField({super.key, required this.routineId});

  final String routineId;

  @override
  ConsumerState<RoutineNameField> createState() => _RoutineNameFieldState();
}

class _RoutineNameFieldState extends ConsumerState<RoutineNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(routineProvider(widget.routineId)).name,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Routine name',
        hintText: 'Untitled routine',
        prefixIcon: Icon(Icons.edit_outlined),
      ),
      onChanged: ref
          .read(routineControllerProvider(widget.routineId).notifier)
          .rename,
    );
  }
}
