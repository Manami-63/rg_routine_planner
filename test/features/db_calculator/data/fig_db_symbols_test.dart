import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/symbols/path_symbol_view.dart';
import 'package:rg_routine_planner/features/db_calculator/data/fig_db_catalogue_repository.dart';
import 'package:rg_routine_planner/features/db_calculator/data/fig_db_symbols.dart';

void main() {
  test('every DB has a symbol inside its box', () async {
    final elements = await const FigDbCatalogueRepository().fetchElements();
    expect(elements, hasLength(70 + 36 + 33));
    for (final element in elements) {
      final path = element.symbolPath;
      expect(path, isNotNull, reason: element.id);
      final bounds = SymbolPath.parse(path!).outline.getBounds();
      expect(bounds.left, greaterThanOrEqualTo(3), reason: element.id);
      expect(bounds.top, greaterThanOrEqualTo(3), reason: element.id);
      expect(bounds.right, lessThanOrEqualTo(117), reason: element.id);
      expect(bounds.bottom, lessThanOrEqualTo(97), reason: element.id);
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
