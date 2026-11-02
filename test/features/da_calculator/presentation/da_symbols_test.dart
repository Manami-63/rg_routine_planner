import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/core/symbols/rg_symbol.dart';
import 'package:rg_routine_planner/core/symbols/rg_symbol_view.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_base.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/widgets/da_symbols.dart';

import '../test_data.dart';

void main() {
  const roll = DaBase(
    id: 'roll',
    name: 'Roll',
    apparatus: Apparatus.ball,
    value: Score.hundredths(30),
    rulesetId: 'test-v1',
    criteria: {},
    symbol: RgSymbol.largeRoll,
  );

  test('needs a symbol for every part', () {
    expect(DaSymbols.canShow(DaElement(base: roll)), isTrue);
    expect(DaSymbols.canShow(DaElement(base: testRoll)), isFalse);
    expect(
      DaSymbols.canShow(DaElement(base: roll, secondBase: testRoll)),
      isFalse,
    );
    expect(
      DaSymbols.canShow(
        DaElement(base: roll, criteria: {DaCriterion.ropeBackward}),
      ),
      isFalse,
    );
  });

  testWidgets('writes the base, then the criteria in table order', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DaSymbols(
            DaElement(
              base: roll,
              criteria: {DaCriterion.rotation, DaCriterion.outsideVisualField},
            ),
          ),
        ),
      ),
    );
    final symbols = tester
        .widgetList<RgSymbolView>(find.byType(RgSymbolView))
        .map((view) => view.symbol);
    expect(symbols, [
      RgSymbol.largeRoll,
      RgSymbol.outsideVisualField,
      RgSymbol.rotation,
    ]);
    expect(find.text('('), findsOneWidget);
  });
}
