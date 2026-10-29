import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/scoring/apparatus.dart';
import '../../../../core/scoring/score.dart';
import '../../../../core/widgets/manual_value_field.dart';
import '../../../../core/widgets/value_badge.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../../domain/da_base.dart';
import '../../domain/da_criterion.dart';
import '../../domain/da_element.dart';
import '../da_calculator_providers.dart';
import '../da_routine_providers.dart';

/// Bottom sheet for building a DA the way it is performed: a base, an
/// optional 2nd base after a catch from a high throw, and the criteria.
/// Criteria that are "N/A" for the base are shown but cannot be chosen.
///
/// Adds a new DA, or replaces the one at [index] when editing. The DA being
/// built is local widget state, discarded if the sheet is dismissed.
class DaBuilderSheet extends ConsumerStatefulWidget {
  const DaBuilderSheet({
    super.key,
    required this.routineId,
    required this.bases,
    this.index,
    this.initial,
  });

  final String routineId;

  /// The bases for the routine's apparatus, in table order.
  final List<DaBase> bases;

  /// The position of the DA being edited, or `null` to add one.
  final int? index;
  final DaElement? initial;

  static Future<void> show(
    BuildContext context, {
    required String routineId,
    required List<DaBase> bases,
    int? index,
    DaElement? initial,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DaBuilderSheet(
        routineId: routineId,
        bases: bases,
        index: index,
        initial: initial,
      ),
    );
  }

  @override
  ConsumerState<DaBuilderSheet> createState() => _DaBuilderSheetState();
}

class _DaBuilderSheetState extends ConsumerState<DaBuilderSheet> {
  // A base that is no longer offered (unknown, or for another apparatus)
  // has to be chosen again.
  late DaBase? _base = _offered(widget.initial?.base);
  late DaBase? _secondBase = _offered(widget.initial?.secondBase);
  late bool _withSecondBase = _secondBase != null;
  late bool _custom = widget.initial?.isCustom ?? false;
  late final _name = TextEditingController(
    text: (widget.initial?.isCustom ?? false) ? widget.initial!.base.name : '',
  );
  late final Set<DaCriterion> _criteria = {...?widget.initial?.criteria};
  late bool _preAcrobatic = widget.initial?.preAcrobatic ?? false;
  late bool _manual = _custom || widget.initial?.manualValue != null;
  late final _manualText = TextEditingController(
    text: widget.initial?.manualValue?.format() ?? '',
  );

  DaBase? _offered(DaBase? base) =>
      base != null && widget.bases.contains(base) ? base : null;

  bool get _isEditing => widget.index != null;

  Score? get _manualValue => Score.tryParse(_manualText.text);

  DaBase? get _effectiveSecondBase => _withSecondBase ? _secondBase : null;

  Set<DaCriterion> get _available => _base == null
      ? const {}
      : ref
            .read(daScoringEngineProvider)
            .availableCriteria(_base!, _effectiveSecondBase);

  /// The DA as currently built, or `null` while incomplete.
  DaElement? get _element {
    final manualValue = _manual ? _manualValue : null;
    if (_custom) {
      final name = _name.text.trim();
      if (name.isEmpty || manualValue == null) return null;
      return DaElement(
        base: DaBase.custom(
          name: name,
          rulesetId: ref.read(routineProvider(widget.routineId)).rulesetId,
        ),
        manualValue: manualValue,
      );
    }
    final base = _base;
    if (base == null || (_withSecondBase && _secondBase == null)) return null;
    if (_manual && manualValue == null) return null;
    final criteria = _criteria.intersection(_available);
    return DaElement(
      base: base,
      secondBase: _effectiveSecondBase,
      criteria: criteria,
      preAcrobatic: _preAcrobatic && criteria.contains(DaCriterion.rotation),
      manualValue: manualValue,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _manualText.dispose();
    super.dispose();
  }

  void _save(DaElement element) {
    final controller = ref.read(
      routineControllerProvider(widget.routineId).notifier,
    );
    if (widget.index case final index?) {
      controller.replaceDaAt(index, element);
    } else {
      controller.addDa(element);
    }
    Navigator.of(context).pop();
  }

  void _chooseBase(DaBase? base, {bool custom = false}) => setState(() {
    _base = base;
    _custom = custom;
    if (custom) _manual = true;
    if (!(base?.startsCombination ?? false)) {
      _withSecondBase = false;
      _secondBase = null;
    }
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final engine = ref.watch(daScoringEngineProvider);
    final apparatus = ref.watch(
      routineProvider(widget.routineId).select((r) => r.apparatus),
    );
    final base = _base;
    final element = _element;

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
            Text(
              _isEditing ? 'Edit DA' : 'Build a DA',
              style: theme.textTheme.titleLarge,
            ),
            const _Header('Base'),
            if (_custom) ...[
              _ChosenBase(
                title: 'A DA not in the list',
                onChange: () => _chooseBase(null),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ] else if (base == null)
              _BaseList(
                bases: widget.bases,
                onChosen: _chooseBase,
                onCustom: () => _chooseBase(null, custom: true),
              )
            else ...[
              _ChosenBase(
                title: base.name,
                note: base.note,
                value: base.value,
                onChange: () => _chooseBase(null),
              ),
              if (base.startsCombination) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Add a 2nd base'),
                  subtitle: const Text(
                    'Without interruption: + 0.10 to the highest base, and '
                    '1 criterion during both bases',
                  ),
                  value: _withSecondBase,
                  onChanged: (on) => setState(() => _withSecondBase = on),
                ),
                if (_withSecondBase)
                  if (_secondBase case final second?)
                    _ChosenBase(
                      title: second.name,
                      note: second.note,
                      value: second.value,
                      onChange: () => setState(() => _secondBase = null),
                    )
                  else
                    _BaseList(
                      bases: [
                        for (final b in widget.bases)
                          if (!b.isCatchFromHighThrow) b,
                      ],
                      onChosen: (b) => setState(() => _secondBase = b),
                    ),
              ],
              ..._criteriaSection(context, apparatus),
            ],
            if (base != null || _custom) ...[
              if (!_custom)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set value manually'),
                  subtitle: const Text(
                    'For rules the app does not cover, e.g. a level with '
                    'other DA rules. Replaces the checks too.',
                  ),
                  value: _manual,
                  onChanged: (on) => setState(() => _manual = on),
                ),
              if (_manual) ...[
                const SizedBox(height: 8),
                ManualValueField(
                  controller: _manualText,
                  onChanged: () => setState(() {}),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('DA value', style: theme.textTheme.titleMedium),
                  ),
                  if (element != null)
                    ValueBadge(
                      key: const ValueKey('da-preview-value'),
                      value: engine.daValue(element),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: element == null ? null : () => _save(element),
                  icon: Icon(_isEditing ? Icons.check : Icons.add),
                  label: Text(_isEditing ? 'Save' : 'Add DA'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _criteriaSection(BuildContext context, Apparatus? apparatus) {
    final theme = Theme.of(context);
    final engine = ref.read(daScoringEngineProvider);
    final available = _available;
    final needed = engine.requiredCriteria(
      DaElement(base: _base!, secondBase: _effectiveSecondBase),
    );
    final chosen = _criteria.intersection(available).length;
    final twoBases = _effectiveSecondBase != null;
    return [
      _Header(
        twoBases
            ? 'Criteria (min. 1, during both bases)'
            : 'Criteria (min. 2, during the base)',
      ),
      for (final criterion in DaCriterion.values)
        if (!criterion.isRopeSpecific || apparatus == Apparatus.rope)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: Text(criterion.label),
            subtitle: available.contains(criterion)
                ? null
                : Text(
                    twoBases ? 'N/A for one of the bases' : 'N/A for this base',
                  ),
            value:
                available.contains(criterion) && _criteria.contains(criterion),
            onChanged: available.contains(criterion)
                ? (on) => setState(
                    () => (on ?? false)
                        ? _criteria.add(criterion)
                        : _criteria.remove(criterion),
                  )
                : null,
          ),
      if (_criteria.contains(DaCriterion.rotation) &&
          available.contains(DaCriterion.rotation))
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('The rotation is a pre-acrobatic element'),
          subtitle: const Text(
            'Max. 3 per routine, each from a different group',
          ),
          value: _preAcrobatic,
          onChanged: (on) => setState(() => _preAcrobatic = on),
        ),
      if (!_manual && chosen < needed)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Choose ${needed - chosen} more to make it a DA.',
            key: const ValueKey('da-criteria-hint'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(title, style: Theme.of(context).textTheme.labelLarge),
  );
}

/// The bases to choose from, with their values.
class _BaseList extends StatelessWidget {
  const _BaseList({required this.bases, required this.onChosen, this.onCustom});

  final List<DaBase> bases;
  final ValueChanged<DaBase> onChosen;

  /// Offers "A DA not in the list" when set.
  final VoidCallback? onCustom;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final base in bases)
          ListTile(
            key: ValueKey('da-base-${base.id}'),
            contentPadding: EdgeInsets.zero,
            title: Text(base.name),
            subtitle: base.note == null ? null : Text(base.note!),
            trailing: ValueBadge(value: base.value),
            onTap: () => onChosen(base),
          ),
        if (onCustom case final onCustom?)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_note),
            title: const Text('A DA not in the list'),
            subtitle: const Text('Enter a name and value yourself'),
            onTap: onCustom,
          ),
      ],
    );
  }
}

/// A chosen base, with a button to choose another one.
class _ChosenBase extends StatelessWidget {
  const _ChosenBase({
    required this.title,
    required this.onChange,
    this.note,
    this.value,
  });

  final String title;
  final String? note;
  final Score? value;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(title),
        subtitle: note == null ? null : Text(note!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value case final value?) ValueBadge(value: value),
            TextButton(onPressed: onChange, child: const Text('Change')),
          ],
        ),
      ),
    );
  }
}
