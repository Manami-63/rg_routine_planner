import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/scoring/score.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../../domain/db_element.dart';
import '../../domain/db_element_options.dart';
import '../db_calculator_providers.dart';
import '../db_routine_providers.dart';
import '../../../../core/widgets/value_badge.dart';

/// Short summary of how an element is performed, e.g. "Flat foot · Slow
/// turn", or `null` when it uses the catalogue value as is.
String? describeOptions(DbElement element, DbElementOptions options) {
  final parts = [
    if (element.isCustom) 'Custom element',
    if (options.manualValue != null && !element.isCustom) 'Manual value',
    if (options.flatFoot) 'Flat foot',
    if (options.slowTurn) 'Slow turn',
    if (options.extraRotations > 0)
      describeRotation(element, options.extraRotations),
    if (element.canBeInSeries && options.seriesCount > 1)
      'Series of ${options.seriesCount}',
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// The total rotation of a rotation DB with [extraRotations] above its
/// base: "3 rotations" for a 360° base, or degrees (e.g. "540°") for the
/// few with a 180° base.
String describeRotation(DbElement element, int extraRotations) {
  if (element.baseRotationDegrees == 360) {
    final total = extraRotations + 1;
    return '$total ${total == 1 ? 'rotation' : 'rotations'}';
  }
  return '${element.baseRotationDegrees + extraRotations * 360}°';
}

/// Bottom sheet for adjusting how one DB of the routine is performed.
///
/// Shows only the options the element allows (flat foot, slow turn,
/// additional rotations), plus a manual value for anything the catalogue
/// does not cover. Changes apply on "Save".
class AdjustElementSheet extends ConsumerStatefulWidget {
  const AdjustElementSheet({
    super.key,
    required this.routineId,
    required this.index,
    required this.element,
    required this.options,
  });

  final String routineId;

  /// Position of the element in the routine.
  final int index;
  final DbElement element;
  final DbElementOptions options;

  static Future<void> show(
    BuildContext context, {
    required String routineId,
    required int index,
    required DbElement element,
    required DbElementOptions options,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => AdjustElementSheet(
        routineId: routineId,
        index: index,
        element: element,
        options: options,
      ),
    );
  }

  @override
  ConsumerState<AdjustElementSheet> createState() => _AdjustElementSheetState();
}

class _AdjustElementSheetState extends ConsumerState<AdjustElementSheet> {
  late bool _flatFoot = widget.options.flatFoot;
  late bool _slowTurn = widget.options.slowTurn;
  late int _extraRotations = widget.options.extraRotations;
  late int _seriesCount = widget.options.seriesCount;

  // Custom elements always use a manual value.
  late bool _manual =
      widget.element.isCustom || widget.options.manualValue != null;
  late final _manualText = TextEditingController(
    text: widget.options.manualValue?.format() ?? '',
  );

  /// Up to 10 Fouetté components (#12.11), each possibly a double: so up to
  /// 20 rotations.
  static const _maxExtraRotations = 20;
  static const _maxSeries = 10;

  DbElement get _element => widget.element;

  Score? get _manualValue => Score.tryParse(_manualText.text);

  bool get _canSave => !_manual || _manualValue != null;

  DbElementOptions _options({bool? flatFoot, bool? slowTurn}) =>
      DbElementOptions(
        flatFoot: flatFoot ?? _flatFoot,
        slowTurn: slowTurn ?? _slowTurn,
        extraRotations: _extraRotations,
        seriesCount: _seriesCount,
        manualValue: _manual ? _manualValue : null,
      );

  @override
  void dispose() {
    _manualText.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(routineControllerProvider(widget.routineId).notifier)
        .setElementOptionsAt(widget.index, _options());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final engine = ref.watch(dbScoringEngineProvider);
    Score valueOf(DbElementOptions options) =>
        engine.elementValue(_element, options);

    // What each option adds on its own, as the engine values it.
    final flatFootDelta =
        valueOf(_options(flatFoot: true, slowTurn: false)) -
        valueOf(_options(flatFoot: false, slowTurn: false));
    final slowTurnDelta =
        valueOf(_options(slowTurn: true)) - valueOf(_options(slowTurn: false));

    final value = _canSave ? valueOf(_options()) : null;
    final structured = !_manual;
    final series = _element.canBeInSeries ? _seriesCount : 1;
    final isRepetition = ref.watch(
      dbScoreResultProvider(widget.routineId)
          .select((r) => r.repeatedElements.contains(widget.index)),
    );

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
            Text(_element.name, style: theme.textTheme.titleLarge),
            if (!_element.isCustom)
              Text(
                'Catalogue value ${_element.value.format()}',
                style: theme.textTheme.bodySmall,
              ),
            if (isRepetition && !_manual) ...[
              const SizedBox(height: 12),
              Text(
                'Not valid: this element repeats an earlier one. Set a value '
                'manually if your level allows repetitions.',
                key: const ValueKey('repetition-note'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (_element.canBeOnFlatFoot && structured) ...[
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: [
                  const ButtonSegment(value: false, label: Text('Relevé')),
                  ButtonSegment(
                    value: true,
                    label: Text('Flat foot (${flatFootDelta.format()})'),
                  ),
                ],
                selected: {_flatFoot},
                onSelectionChanged: (selection) =>
                    setState(() => _flatFoot = selection.single),
              ),
            ],
            if (_element.canSlowTurn && structured)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Slow turn'),
                subtitle: Text(
                  '+${slowTurnDelta.format()} '
                  '${_flatFoot ? 'on flat foot' : 'on relevé'}',
                ),
                value: _slowTurn,
                onChanged: (on) => setState(() => _slowTurn = on),
              ),
            if (_element.extraRotationValue case final perRotation?
                when structured)
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Total rotation'),
                      subtitle: Text(
                        _element.baseRotationDegrees == 360
                            ? '${(_extraRotations + 1) * 360}° · '
                                  '+${perRotation.format()} for each after '
                                  'the first'
                            : '+${perRotation.format()} for each 360° after '
                                  'the first ${_element.baseRotationDegrees}°',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fewer rotations',
                    icon: const Icon(Icons.remove),
                    onPressed: _extraRotations == 0
                        ? null
                        : () => setState(() => _extraRotations--),
                  ),
                  Text(
                    _element.baseRotationDegrees == 360
                        ? '${_extraRotations + 1}'
                        : '${_element.baseRotationDegrees + _extraRotations * 360}°',
                    key: const ValueKey('total-rotation'),
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    tooltip: 'More rotations',
                    icon: const Icon(Icons.add),
                    onPressed: _extraRotations == _maxExtraRotations
                        ? null
                        : () => setState(() => _extraRotations++),
                  ),
                ],
              ),
            if (_element.canBeInSeries)
              Row(
                children: [
                  const Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Performed in a series of'),
                      subtitle: Text('Each one counts as 1 DB'),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Shorter series',
                    icon: const Icon(Icons.remove),
                    onPressed: _seriesCount == 1
                        ? null
                        : () => setState(() => _seriesCount--),
                  ),
                  Text(
                    '$_seriesCount',
                    key: const ValueKey('series-count'),
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    tooltip: 'Longer series',
                    icon: const Icon(Icons.add),
                    onPressed: _seriesCount == _maxSeries
                        ? null
                        : () => setState(() => _seriesCount++),
                  ),
                ],
              ),
            if (!_element.isCustom)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set value manually'),
                subtitle: const Text(
                  'For values the app does not cover, e.g. a newly approved '
                  'element or a national value table',
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
                  child: Text(
                    series > 1 && value != null
                        ? 'Value ($series × ${value.format()})'
                        : 'Value',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (value != null)
                  ValueBadge(
                    key: const ValueKey('adjust-preview-value'),
                    value: value * series,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A text field for a value such as `0.40`, with an error for invalid
/// input.
class ManualValueField extends StatelessWidget {
  const ManualValueField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: 'Value',
        hintText: 'e.g. 0.40',
        border: const OutlineInputBorder(),
        errorText: text.isEmpty || Score.tryParse(text) != null
            ? null
            : 'Enter a value like 0.40',
      ),
      onChanged: (_) => onChanged(),
    );
  }
}
