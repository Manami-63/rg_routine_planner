import 'package:flutter/material.dart';

import '../../../core/floor/floor_cell.dart';
import '../../levels/presentation/count_limit_notice.dart';
import '../../routines/domain/routine.dart';
import '../domain/floor_checks.dart';
import '../domain/routine_timeline.dart';

/// Use of the space (CoP #9) notices for the routine's floor locations:
/// zones not reached (#9.2), zones only passed through, and 3 or more
/// Difficulties in a row in the same cell (#9.4.1).
///
/// Advisory only. Shows nothing until some item has a location.
class FloorNotices extends StatelessWidget {
  const FloorNotices({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final report = floorZoneReport(routine);
    if (report == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final missing = report.missing;
    final runs = samePlacementRuns(routine);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (missing.isNotEmpty)
            LevelNotice(
              key: const ValueKey('floor-zones-notice'),
              icon: Icons.warning_amber_rounded,
              background: colors.errorContainer,
              foreground: colors.onErrorContainer,
              message:
                  'No marked item in the ${_list(missing.map(_zoneName))}. '
                  'All 5 zones of the floor should be visited (CoP #9.2): '
                  'you may get a 0.30 penalty (#9.2.1).',
            ),
          for (final MapEntry(key: zone, value: (from, to))
              in report.passedBy.entries)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LevelNotice(
                key: ValueKey('floor-passed-${zone.number}'),
                icon: Icons.info_outline,
                background: colors.secondaryContainer,
                foreground: colors.onSecondaryContainer,
                message:
                    '${_capitalised(_zoneName(zone))}: only passed through '
                    'between ${_label(from)} and ${_label(to)} (a '
                    'straight-line guess). Check the path.',
              ),
            ),
          for (final run in runs)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LevelNotice(
                key: ValueKey('floor-run-${_label(run.first)}'),
                icon: Icons.warning_amber_rounded,
                background: colors.errorContainer,
                foreground: colors.onErrorContainer,
                message:
                    '${_list(run.map(_label))} are all in cell '
                    '${run.first.cell!.number}: the same placement for 3 or '
                    'more Difficulties in a row (CoP #9.4.1) may get a 0.30 '
                    'penalty.',
              ),
            ),
        ],
      ),
    );
  }

  static String _label(TimelineEntry entry) =>
      '${entry.kind.label} ${entry.index + 1}';

  static String _zoneName(FloorCell zone) => zone == FloorCell.centre
      ? 'centre'
      : '${zone.label.toLowerCase()} corner';

  static String _capitalised(String text) =>
      text[0].toUpperCase() + text.substring(1);

  /// e.g. "a, b and c".
  static String _list(Iterable<String> items) {
    final list = items.toList();
    return list.length == 1
        ? list.single
        : '${list.sublist(0, list.length - 1).join(', ')} and ${list.last}';
  }
}
