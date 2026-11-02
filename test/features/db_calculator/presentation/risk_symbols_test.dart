import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/symbols/rg_symbol.dart';
import 'package:rg_routine_planner/core/symbols/rg_symbol_view.dart';
import 'package:rg_routine_planner/features/db_calculator/data/fig_risks.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/widgets/risk_symbols.dart';

void main() {
  RiskCriterion criterion(String id) =>
      figRiskCriteria.singleWhere((c) => c.id == 'fig-r-$id');
  final four = figRiskRotationOptions.singleWhere((o) => o.rotations == 4);

  test('every criterion but the Rope ones has a symbol', () {
    final missing = [
      for (final c in figRiskCriteria)
        if (c.symbol == null) c.id,
    ];
    expect(missing, [
      'fig-r-throw-passing-through-rope',
      'fig-r-throw-open-rope-by-end',
      'fig-r-throw-open-rope-by-middle',
      'fig-r-catch-rope-end-in-each-hand',
    ]);
  });

  test('needs a symbol for every part', () {
    expect(RiskSymbols.canShow(RiskElement(rotation: four)), isTrue);
    expect(
      RiskSymbols.canShow(
        RiskElement(
          rotation: four,
          criteria: [criterion('throw-passing-through-rope')],
        ),
      ),
      isFalse,
    );
  });

  testWidgets('writes throw, rotations, then catch like a coach', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RiskSymbols(
            RiskElement(
              rotation: four,
              criteria: [
                criterion('throw-outside-visual-field'),
                criterion('throw-without-hands'),
                criterion('change-of-axis-or-level'),
                criterion('catch-outside-visual-field'),
              ],
            ),
          ),
        ),
      ),
    );

    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    String describe(Widget widget) => switch (widget) {
      RgSymbolView(:final symbol) => symbol.name,
      Text(:final data) => data!,
      _ => '?',
    };
    expect(wrap.children.map(describe), [
      '(',
      RgSymbol.outsideVisualField.name,
      RgSymbol.withoutHands.name,
      ')',
      'R4',
      RgSymbol.changeOfAxisOrLevel.name,
      RgSymbol.outsideVisualField.name,
    ]);
  });
}
