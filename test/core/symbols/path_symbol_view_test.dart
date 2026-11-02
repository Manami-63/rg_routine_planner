import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/symbols/path_symbol_view.dart';

void main() {
  test('reads every command', () {
    final symbol = SymbolPath.parse(
      'M0 0L10 10Q20 20 30 30C1 2 3 4 5 6O40 40 5D50 50 2',
    );
    expect(symbol.outline.getBounds().right, greaterThan(40));
    expect(symbol.dots, hasLength(1));
  });

  test('rejects an unknown command', () {
    expect(() => SymbolPath.parse('M0 0Z'), throwsFormatException);
  });

  testWidgets('sizes by the height and reads its label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: PathSymbolView('M0 0L9 9', label: 'A', size: 20)),
      ),
    );
    expect(tester.getSize(find.byType(CustomPaint).last), const Size(24, 20));
    expect(find.bySemanticsLabel('A'), findsOneWidget);
  });
}
