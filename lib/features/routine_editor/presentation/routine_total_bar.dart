import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../da_calculator/domain/da_scoring_engine.dart';
import '../../db_calculator/domain/db_scoring_engine.dart';
import '../domain/routine_score.dart';
import '../../da_calculator/presentation/da_routine_providers.dart';
import '../../db_calculator/presentation/db_routine_providers.dart';

/// Sticky bottom bar of the routine page: the provisional total, its DB and
/// DA parts, and a breakdown for the open tab (body difficulties and risks
/// on the DB and R tabs, DA counted on the DA tab).
class RoutineTotalBar extends ConsumerWidget {
  const RoutineTotalBar({
    super.key,
    required this.routineId,
    required this.showDa,
  });

  final String routineId;

  /// Whether the DA tab is open.
  final bool showDa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Built here from the results the tabs show. (A provider combining them
    // would be refreshed during the build that resumes this page after a
    // full-screen form closes, which Riverpod rejects.)
    final score = RoutineScore(
      db: ref.watch(dbScoreResultProvider(routineId)),
      da: ref.watch(daScoreResultProvider(routineId)),
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final detailStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final partStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Material(
      color: colors.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.isProvisional
                          ? 'Provisional difficulty total'
                          : 'Difficulty total',
                      style: theme.textTheme.labelLarge,
                    ),
                    Row(
                      children: [
                        Text('DB ', style: partStyle),
                        Text(
                          score.db.subtotal.format(),
                          key: const ValueKey('db-subtotal'),
                          style: partStyle,
                        ),
                        Text(' + DA ', style: partStyle),
                        Text(
                          score.da.subtotal.format(),
                          key: const ValueKey('da-subtotal'),
                          style: partStyle,
                        ),
                      ],
                    ),
                    Text(
                      showDa ? _daBreakdown(score.da) : _dbBreakdown(score.db),
                      key: ValueKey(showDa ? 'da-breakdown' : 'db-breakdown'),
                      style: detailStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                score.total.format(),
                key: const ValueKey('routine-total'),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              IconButton(
                tooltip: 'About this total',
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showAbout(context, score),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _dbBreakdown(DbScoreResult db) =>
      'Body ${db.bodySubtotal.format()}'
      '${_countedOf(db.countedElementCount, db.elementCount)}'
      ' · Risks ${db.riskSubtotal.format()}'
      '${_countedOf(db.countedRiskCount, db.riskCount)}';

  static String _daBreakdown(DaScoreResult da) => da.countedCount == da.daCount
      ? '${da.daCount} DA'
      : '${da.countedCount} of ${da.daCount} DA counted';

  void _showAbout(BuildContext context, RoutineScore score) {
    final db = score.db;
    final da = score.da;
    final lines = [
      'Based on ${db.ruleset.label}.',
      'DB ${db.subtotal.format()} (body difficulties and risks) + '
          'DA ${da.subtotal.format()} = ${score.total.format()}.',
      if (db.notices.contains(DbScoreNotice.rulesNotValidated))
        db.countLimitsApplied
            ? 'DB: only count limits applied.'
            : 'DB: no rule checks applied.',
      if (da.notices.contains(DaScoreNotice.rulesNotValidated))
        'DA: execution of bases and criteria not checked.',
      'Penalties are never deducted.',
    ];
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About this total'),
        content: Text(lines.join('\n\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// e.g. " (6 of 8)" when some are not counted, otherwise nothing.
String _countedOf(int counted, int total) =>
    counted == total ? '' : ' ($counted of $total)';
