import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/db_element_group.dart';
import '../domain/competition_level.dart';
import '../domain/count_limit.dart';
import '../domain/difficulty_category.dart';
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
    required this.apparatus,
    required this.onChanged,
  });

  final CompetitionLevel? level;

  /// The routine's apparatus; freehand routines show freehand limits.
  final Apparatus? apparatus;
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
              ? 'Used to decide which difficulties count'
              : describeLevel(level, apparatus),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => LevelPickerSheet.show(
          context,
          initialLevel: level,
          apparatus: apparatus,
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
    required this.apparatus,
    required this.onApply,
  });

  final CompetitionLevel? initialLevel;
  final Apparatus? apparatus;

  /// Called with the chosen level, or `null` when the level is removed.
  final ValueChanged<CompetitionLevel?> onApply;

  static Future<void> show(
    BuildContext context, {
    required CompetitionLevel? initialLevel,
    required Apparatus? apparatus,
    required ValueChanged<CompetitionLevel?> onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // Stays below the status bar when the content is tall.
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => LevelPickerSheet(
        initialLevel: initialLevel,
        apparatus: apparatus,
        onApply: onApply,
      ),
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

  List<DifficultyCategory> get _categories => categoriesFor(widget.apparatus);

  /// Minimums are rarely needed, so they stay hidden until asked for.
  late bool _showMinimums = _categories.any(
    (category) => category.limitOf(_custom).min != null,
  );

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
                      subtitle: Text(describeLevel(level, widget.apparatus)),
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
                child: _CustomRequirementsEditor(
                  requirements: _custom,
                  categories: _categories,
                  showMinimums: _showMinimums,
                  onChanged: (custom) => setState(() => _custom = custom),
                  onShowMinimumsChanged: (show) => setState(() {
                    _showMinimums = show;
                    // Hidden minimums would still be checked, so clear them.
                    if (!show) {
                      for (final category in _categories) {
                        _custom = _custom.withLimit(
                          category,
                          category.limitOf(_custom).withMin(null),
                        );
                      }
                    }
                  }),
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

/// The numbers, required body groups and dance steps of a non-FIG level.
class _CustomRequirementsEditor extends StatelessWidget {
  const _CustomRequirementsEditor({
    required this.requirements,
    required this.categories,
    required this.showMinimums,
    required this.onChanged,
    required this.onShowMinimumsChanged,
  });

  final LevelRequirements requirements;

  /// The categories that apply to the routine (freehand has no risks).
  final List<DifficultyCategory> categories;
  final bool showMinimums;
  final ValueChanged<LevelRequirements> onChanged;
  final ValueChanged<bool> onShowMinimumsChanged;

  void _toggleGroup(DbElementGroup group, bool selected) => onChanged(
    requirements.copyWith(
      requiredBodyGroups: selected
          ? {...requirements.requiredBodyGroups, group}
          : ({...requirements.requiredBodyGroups}..remove(group)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Counted per routine', style: theme.textTheme.titleSmall),
              Text(
                'More can be performed; the extra ones do not count.',
                style: theme.textTheme.bodySmall,
              ),
              for (final category in categories)
                _LimitRow(
                  category: category,
                  limit: category.limitOf(requirements),
                  showMinimum: showMinimums,
                  onChanged: (limit) =>
                      onChanged(requirements.withLimit(category, limit)),
                ),
              TextButton.icon(
                onPressed: () => onShowMinimumsChanged(!showMinimums),
                icon: Icon(showMinimums ? Icons.remove : Icons.add),
                label: Text(showMinimums ? 'Remove minimums' : 'Add minimums'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Required body groups', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final group in DbElementGroup.requirable)
              FilterChip(
                label: Text(group.label),
                selected: requirements.requiredBodyGroups.contains(group),
                onSelected: (selected) => _toggleGroup(group, selected),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Required dance steps combinations (S)',
          style: theme.textTheme.titleSmall,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: _OptionalCountStepper(
            label: 'Minimum',
            semanticName: 'S minimum',
            value: requirements.minDanceSteps,
            onChanged: (min) => onChanged(requirements.withMinDanceSteps(min)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Levels can have other requirements too (e.g. split line, "
                "value limits). Check your level's rules.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Maximum (and optionally minimum) steppers for one category.
class _LimitRow extends StatelessWidget {
  const _LimitRow({
    required this.category,
    required this.limit,
    required this.showMinimum,
    required this.onChanged,
  });

  final DifficultyCategory category;
  final CountLimit limit;
  final bool showMinimum;
  final ValueChanged<CountLimit> onChanged;

  String get _title => switch (category) {
    DifficultyCategory.db => 'Body difficulties (DB)',
    DifficultyCategory.risk => 'Risks (R)',
    DifficultyCategory.da => 'Apparatus difficulties (DA)',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = limit.max;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title, style: theme.textTheme.bodyMedium),
          if (max != null)
            Text(category.countedRule(max), style: theme.textTheme.bodySmall),
          Row(
            children: [
              if (showMinimum)
                Expanded(
                  child: _OptionalCountStepper(
                    label: 'Minimum',
                    semanticName: '${category.noun} minimum',
                    value: limit.min,
                    onChanged: (min) => onChanged(limit.withMin(min)),
                  ),
                ),
              Expanded(
                child: _OptionalCountStepper(
                  label: 'Maximum',
                  semanticName: '${category.noun} maximum',
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
