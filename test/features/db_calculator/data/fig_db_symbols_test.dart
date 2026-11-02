import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/symbols/path_symbol_view.dart';
import 'package:rg_routine_planner/features/db_calculator/data/fig_db_catalogue_repository.dart';
import 'package:rg_routine_planner/features/db_calculator/data/fig_db_symbols.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';

void main() {
  test('every balance has a symbol that draws inside its box', () async {
    final elements = await const FigDbCatalogueRepository().fetchElements();
    final balances = elements.where((e) => e.group == DbElementGroup.balance);
    expect(balances, hasLength(36));
    for (final balance in balances) {
      final path = balance.symbolPath;
      expect(path, isNotNull, reason: balance.id);
      final bounds = SymbolPath.parse(path!).outline.getBounds();
      expect(bounds.left, greaterThanOrEqualTo(3), reason: balance.id);
      expect(bounds.top, greaterThanOrEqualTo(3), reason: balance.id);
      expect(bounds.right, lessThanOrEqualTo(117), reason: balance.id);
      expect(bounds.bottom, lessThanOrEqualTo(97), reason: balance.id);
    }
  });

  test('every symbol belongs to an element', () async {
    final elements = await const FigDbCatalogueRepository().fetchElements();
    final ids = elements.map((e) => e.id).toSet();
    for (final code in figDbSymbolPaths.keys) {
      expect(ids, contains('fig-$code'));
    }
  });
}
