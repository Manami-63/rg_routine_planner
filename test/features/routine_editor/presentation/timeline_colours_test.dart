import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/theme/app_theme.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/routine_timeline.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/timeline_colours.dart';

void main() {
  final light = AppTheme.light().colorScheme;
  final dark = AppTheme.dark().colorScheme;

  test('each kind and a pair have their own colour', () {
    for (final scheme in [light, dark]) {
      final colours = {
        for (final kind in TimelineKind.values)
          ItemColours.of(kind, scheme).colour,
        ItemColours.pair(scheme).colour,
      };
      expect(colours, hasLength(TimelineKind.values.length + 1));
    }
  });

  test('dark mode uses lighter tones than light mode', () {
    for (final kind in TimelineKind.values) {
      expect(
        ItemColours.of(kind, dark).colour.computeLuminance(),
        greaterThan(ItemColours.of(kind, light).colour.computeLuminance()),
        reason: kind.name,
      );
    }
  });

  test('text on each colour is readable (contrast 4.5:1)', () {
    double contrast(Color a, Color b) {
      final (l1, l2) = (a.computeLuminance(), b.computeLuminance());
      return (l1 > l2 ? l1 + 0.05 : l2 + 0.05) /
          (l1 > l2 ? l2 + 0.05 : l1 + 0.05);
    }

    for (final scheme in [light, dark]) {
      for (final colours in [
        for (final kind in TimelineKind.values) ItemColours.of(kind, scheme),
        ItemColours.pair(scheme),
      ]) {
        expect(contrast(colours.colour, colours.onColour), greaterThan(4.5));
        expect(
          contrast(colours.container, colours.onContainer),
          greaterThan(4.5),
        );
        expect(contrast(colours.colour, scheme.surface), greaterThan(3));
      }
    }
  });
}
