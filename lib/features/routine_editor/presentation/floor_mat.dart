import 'package:flutter/material.dart';

import '../../../core/floor/floor_cell.dart';
import '../domain/routine_timeline.dart';

/// The floor area as a 3 x 3 grid, front (judges) at the bottom, with the
/// 5 zones shaded as in the CoP picture (#9.2.1.A).
///
/// Optionally shows [entries] in their cells with the path between them,
/// highlights a cell, reacts to taps, and accepts dragged [T] data (e.g. a
/// "Next DB" button dropped on a cell).
class FloorMat<T extends Object> extends StatelessWidget {
  const FloorMat({
    super.key,
    this.entries = const [],
    this.highlighted,
    this.onTap,
    this.onDrop,
    this.showJudges = true,
  });

  /// Located items to show, in time order; the path joins them.
  final List<TimelineEntry> entries;

  final FloorCell? highlighted;
  final ValueChanged<FloorCell>? onTap;

  /// Called when [T] data is dropped on a cell.
  final void Function(T data, FloorCell cell)? onDrop;

  /// Whether to label the front with "Judges".
  final bool showJudges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final located = [
      for (final entry in entries)
        if (entry.cell != null) entry,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    for (var row = 0; row < 3; row++)
                      Expanded(
                        child: Row(
                          children: [
                            for (var column = 0; column < 3; column++)
                              Expanded(
                                child: _cell(
                                  context,
                                  FloorCell.at(row, column),
                                  located,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (located.length > 1)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _PathPainter(
                        cells: [for (final e in located) e.cell!],
                        color: colors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showJudges)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Front · Judges',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    FloorCell cell,
    List<TimelineEntry> located,
  ) {
    final colors = Theme.of(context).colorScheme;
    final labels = [
      for (final entry in located)
        if (entry.cell == cell) '${entry.kind.label}${entry.index + 1}',
    ];

    Widget content(bool hovering) => Container(
      key: ValueKey('floor-cell-${cell.number}'),
      decoration: BoxDecoration(
        color: hovering || cell == highlighted
            ? colors.primaryContainer
            : cell.isZone
            ? colors.surfaceContainerHighest
            : colors.surface,
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Text(
            '${cell.number}',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (labels.isNotEmpty)
            Center(
              child: Text(
                labels.length > 4
                    ? '${labels.take(3).join(' ')} +${labels.length - 3}'
                    : labels.join(' '),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );

    final onDrop = this.onDrop;
    final onTap = this.onTap;
    Widget child = onDrop == null
        ? content(false)
        : DragTarget<T>(
            onAcceptWithDetails: (details) => onDrop(details.data, cell),
            builder: (context, candidates, _) => content(candidates.isNotEmpty),
          );
    if (onTap != null) {
      child = Semantics(
        button: true,
        label: '${cell.label} (cell ${cell.number})',
        child: InkWell(onTap: () => onTap(cell), child: child),
      );
    }
    return child;
  }
}

/// Straight lines between the middles of consecutive cells.
class _PathPainter extends CustomPainter {
  _PathPainter({required this.cells, required this.color});

  final List<FloorCell> cells;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Offset middle(FloorCell cell) => Offset(
      (cell.column + 0.5) * size.width / 3,
      (cell.row + 0.5) * size.height / 3,
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(middle(cells.first).dx, middle(cells.first).dy);
    for (final cell in cells.skip(1)) {
      path.lineTo(middle(cell).dx, middle(cell).dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.color != color ||
      old.cells.length != cells.length ||
      !_sameCells(old.cells, cells);

  static bool _sameCells(List<FloorCell> a, List<FloorCell> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
