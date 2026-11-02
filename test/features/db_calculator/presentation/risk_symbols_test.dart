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

  test('every criterion has a symbol', () {
    for (final criterion in figRiskCriteria) {
      expect(criterion.symbol, isNotNull, reason: criterion.id);
    }
  });

  test('needs a symbol for every part', () {
    expect(RiskSymbols.canShow(RiskElement(rotation: four)), isTrue);
    expect(
      RiskSymbols.canShow(
        RiskElement(
          rotation: four,
          criteria: [const RiskCriterion.unknown(id: 'gone', rulesetId: 'x')],
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
