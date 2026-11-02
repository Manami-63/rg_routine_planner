import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/scoring/score.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../../domain/db_element.dart';
import '../../domain/db_element_options.dart';
import '../db_routine_providers.dart';
import '../../../../core/widgets/manual_value_field.dart';

/// Bottom sheet for adding a DB that is not in the catalogue, e.g. one
/// newly approved by FIG during the Olympic cycle.
class CustomElementSheet extends ConsumerStatefulWidget {
  const CustomElementSheet({
    super.key,
    required this.routineId,
    this.replaceIndex,
  });

  final String routineId;

  /// The element it replaces, or `null` to add one.
  final int? replaceIndex;

  static Future<void> show(
    BuildContext context, {
    required String routineId,
    int? replaceIndex,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          CustomElementSheet(routineId: routineId, replaceIndex: replaceIndex),
    );
  }

  @override
  ConsumerState<CustomElementSheet> createState() => _CustomElementSheetState();
}

class _CustomElementSheetState extends ConsumerState<CustomElementSheet> {
  final _name = TextEditingController();
  final _value = TextEditingController();
  DbElementGroup? _group;

  Score? get _parsedValue => Score.tryParse(_value.text);

  bool get _canAdd =>
      _name.text.trim().isNotEmpty && _group != null && _parsedValue != null;

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  void _add() {
    final routine = ref.read(routineProvider(widget.routineId));
    final controller = ref.read(
      routineControllerProvider(widget.routineId).notifier,
    );
    final element = DbElement.custom(
      name: _name.text.trim(),
      group: _group!,
      rulesetId: routine.rulesetId,
    );
    if (widget.replaceIndex case final index?) {
      controller.replaceElementAt(
        index,
        element,
        DbElementOptions(manualValue: _parsedValue),
      );
    } else {
      controller.addCustomElement(element, _parsedValue!);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add an element', style: theme.textTheme.titleLarge),
            Text(
              'For a DB that is not in the list, e.g. newly approved by FIG.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final group in DbElementGroup.requirable)
                  ChoiceChip(
                    label: Text(group.label),
                    selected: _group == group,
                    onSelected: (_) => setState(() => _group = group),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ManualValueField(
              controller: _value,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canAdd ? _add : null,
                icon: const Icon(Icons.add),
                label: const Text('Add element'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
