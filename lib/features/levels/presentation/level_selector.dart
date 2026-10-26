import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/competition_level.dart';
import '../domain/count_limit.dart';
import 'level_providers.dart';
import 'limit_text.dart';

/// Shows a routine's level and opens the level picker.
///
/// Takes the level and a callback instead of reading a provider, so this
/// feature does not depend on where the level is stored.
class LevelSelector extends StatelessWidget {
  const LevelSelector({
    super.key,
    required this.level,
    required this.onChanged,
  });

  final CompetitionLevel? level;
  final ValueChanged<CompetitionLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    final level = this.level;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: Text(level?.label ?? 'Select a level'),
        subtitle: Text(
          level == null
              ? 'Used to check the number of DB and DA'
              : describeRequirements(level.requirements),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => LevelPickerSheet.show(
          context,
          initialLevel: level,
          onApply: onChanged,
        ),
      ),
    );
  }
}

/// Bottom sheet for choosing a FIG level or entering a non-FIG level.
///
/// The choice is held in local state and only applied on "Apply", so
/// dismissing the sheet changes nothing.
class LevelPickerSheet extends ConsumerStatefulWidget {
  const LevelPickerSheet({
    super.key,
    required this.initialLevel,
    required this.onApply,
  });

  final CompetitionLevel? initialLevel;

  /// Called with the chosen level, or `null` when the level is removed.
  final ValueChanged<CompetitionLevel?> onApply;

  static Future<void> show(
    BuildContext context, {
    required CompetitionLevel? initialLevel,
    required ValueChanged<CompetitionLevel?> onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          LevelPickerSheet(initialLevel: initialLevel, onApply: onApply),
    );
  }

  @override
  ConsumerState<LevelPickerSheet> createState() => _LevelPickerSheetState();
}

class _LevelPickerSheetState extends ConsumerState<LevelPickerSheet> {
  late final CompetitionLevel? _current = widget.initialLevel;
  late String? _selectedId = _current?.id;
  late LevelRequirements _custom = (_current?.isCustom ?? false)
      ? _current!.requirements!
      : const LevelRequirements();

  bool get _isCustom => _selectedId == CompetitionLevel.customId;

  bool get _canApply => _selectedId != null && (!_isCustom || _custom.isValid);

  void _apply() {
    final level = _isCustom
        ? CompetitionLevel.custom(_custom)
        : ref
              .read(presetLevelsProvider)
              .firstWhere((level) => level.id == _selectedId);
    widget.onApply(level);
    Navigator.of(context).pop();
  }

  void _removeLevel() {
    widget.onApply(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = ref.watch(presetLevelsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Level', style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _selectedId,
              onChanged: (id) => setState(() => _selectedId = id),
              child: Column(
                children: [
                  for (final level in presets)
                    RadioListTile<String>(
                      value: level.id,
                      title: Text(level.label),
                      subtitle: Text(describeRequirements(level.requirements)),
                    ),
                  const RadioListTile<String>(
                    value: CompetitionLevel.customId,
                    title: Text('Non-FIG level'),
                    subtitle: Text(
                      'National or club levels: enter the requirements',
                    ),
                  ),
                ],
              ),
            ),
            if (_isCustom)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    _LimitEditor(
                      category: 'DB',
                      limit: _custom.db,
                      onChanged: (db) =>
                          setState(() => _custom = _custom.copyWith(db: db)),
                    ),
                    const SizedBox(height: 12),
                    _LimitEditor(
                      category: 'DA',
                      limit: _custom.da,
                      onChanged: (da) =>
                          setState(() => _custom = _custom.copyWith(da: da)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (_current != null)
                    TextButton(
                      onPressed: _removeLevel,
                      child: const Text('Remove level'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _canApply ? _apply : null,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimum and maximum steppers for one category (DB or DA).
class _LimitEditor extends StatelessWidget {
  const _LimitEditor({
    required this.category,
    required this.limit,
    required this.onChanged,
  });

  final String category;
  final CountLimit limit;
  final ValueChanged<CountLimit> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Number of $category', style: theme.textTheme.titleSmall),
          Row(
            children: [
              Expanded(
                child: _OptionalCountStepper(
                  label: 'Minimum',
                  semanticName: '$category minimum',
                  value: limit.min,
                  onChanged: (min) => onChanged(limit.withMin(min)),
                ),
              ),
              Expanded(
                child: _OptionalCountStepper(
                  label: 'Maximum',
                  semanticName: '$category maximum',
                  value: limit.max,
                  onChanged: (max) => onChanged(limit.withMax(max)),
                ),
              ),
            ],
          ),
          if (!limit.isValid)
            Text(
              'Minimum cannot be more than maximum',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }
}

/// A −/+ stepper whose lowest setting is "Any" (no requirement).
class _OptionalCountStepper extends StatelessWidget {
  const _OptionalCountStepper({
    required this.label,
    required this.semanticName,
    required this.value,
    required this.onChanged,
  });

  static const _maxValue = 20;

  final String label;
  final String semanticName;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Decrease $semanticName',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove),
              // 1 steps down to "Any" rather than 0.
              onPressed: value == null
                  ? null
                  : () => onChanged(value <= 1 ? null : value - 1),
            ),
            SizedBox(
              width: 36,
              child: Text(
                value?.toString() ?? 'Any',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Increase $semanticName',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add),
              onPressed: (value ?? 0) >= _maxValue
                  ? null
                  : () => onChanged((value ?? 0) + 1),
            ),
          ],
        ),
      ],
    );
  }
}
