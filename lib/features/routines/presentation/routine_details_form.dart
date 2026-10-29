import 'package:flutter/material.dart';

import '../../../core/scoring/apparatus.dart';
import '../../levels/domain/competition_level.dart';
import '../../levels/presentation/level_selector.dart';
import '../domain/routine.dart';
import 'apparatus_selector.dart';

/// A routine's name, apparatus and level: what the details form edits.
class RoutineDetails {
  const RoutineDetails({this.name = '', this.apparatus, this.level});

  RoutineDetails.of(Routine routine)
    : name = routine.name,
      apparatus = routine.apparatus,
      level = routine.level;

  final String name;
  final Apparatus? apparatus;
  final CompetitionLevel? level;

  /// [routine] with these details.
  Routine applyTo(Routine routine) =>
      routine.rename(name).withApparatus(apparatus).withLevel(level);
}

/// The name shown for a routine, e.g. in titles and lists.
String routineDisplayName(String name) =>
    name.trim().isEmpty ? 'Untitled routine' : name;

/// One line with the apparatus and level, e.g. "Hoop · FIG Senior".
String describeRoutineDetails(Apparatus? apparatus, CompetitionLevel? level) =>
    '${apparatus?.label ?? 'No apparatus'} · ${level?.label ?? 'No level'}';

/// Full-screen form for a routine's name, apparatus and level, used when
/// creating a routine and when editing one.
///
/// Changes are held in local state and only returned on "Create"/"Save",
/// so closing the form changes nothing. A new routine needs an apparatus,
/// because risks and DA depend on it; older routines without one can still
/// be edited.
class RoutineDetailsForm extends StatefulWidget {
  const RoutineDetailsForm({
    super.key,
    required this.initial,
    required this.isNew,
    this.hasApparatusContent = false,
  });

  final RoutineDetails initial;
  final bool isNew;

  /// Whether the routine has risks or DA, which depend on the apparatus.
  final bool hasApparatusContent;

  /// Opens the form for a new routine; returns the details, or `null` if
  /// it was closed.
  static Future<RoutineDetails?> create(BuildContext context) => _show(
    context,
    const RoutineDetailsForm(initial: RoutineDetails(), isNew: true),
  );

  /// Opens the form for [routine]; returns the new details, or `null` if
  /// it was closed.
  static Future<RoutineDetails?> edit(BuildContext context, Routine routine) =>
      _show(
        context,
        RoutineDetailsForm(
          initial: RoutineDetails.of(routine),
          isNew: false,
          hasApparatusContent:
              routine.db.risks.isNotEmpty || !routine.da.isEmpty,
        ),
      );

  static Future<RoutineDetails?> _show(
    BuildContext context,
    RoutineDetailsForm form,
  ) => Navigator.of(context)
      .push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => form));

  @override
  State<RoutineDetailsForm> createState() => _RoutineDetailsFormState();
}

class _RoutineDetailsFormState extends State<RoutineDetailsForm> {
  late final _name = TextEditingController(text: widget.initial.name);
  late Apparatus? _apparatus = widget.initial.apparatus;
  late CompetitionLevel? _level = widget.initial.level;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(
    RoutineDetails(
      name: _name.text.trim(),
      apparatus: _apparatus,
      level: _level,
    ),
  );

  /// Shown when changing the apparatus of a routine that already has
  /// risks or DA. They are kept, so changing back restores them.
  String? get _apparatusNote {
    final before = widget.initial.apparatus;
    if (!widget.hasApparatusContent || before == null || _apparatus == before) {
      return null;
    }
    return _apparatus == Apparatus.freehand
        ? 'Freehand routines have no risks or DA, so the ones in this '
              'routine will not count. They are kept, not deleted.'
        : 'DA and risk criteria for ${before.label} may not count for '
              '${_apparatus!.label}. They are kept, not deleted.';
  }

  @override
  Widget build(BuildContext context) {
    final note = _apparatusNote;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.isNew ? 'New routine' : 'Edit routine'),
        actions: [
          TextButton(
            onPressed: _apparatus == null && widget.isNew ? null : _submit,
            child: Text(widget.isNew ? 'Create' : 'Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Routine name',
              hintText: 'Untitled routine',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(height: 16),
          ApparatusSelector(
            apparatus: _apparatus,
            onChanged: (apparatus) => setState(() => _apparatus = apparatus),
          ),
          if (_apparatus == null) ...[
            const SizedBox(height: 4),
            Text(
              'Choose an apparatus: risks and DA depend on it.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 8),
            Text(
              note,
              key: const ValueKey('apparatus-change-note'),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.error),
            ),
          ],
          const SizedBox(height: 16),
          LevelSelector(
            level: _level,
            apparatus: _apparatus,
            onChanged: (level) => setState(() => _level = level),
          ),
        ],
      ),
    );
  }
}
