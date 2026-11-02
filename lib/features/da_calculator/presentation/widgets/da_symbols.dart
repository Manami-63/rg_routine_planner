import 'package:flutter/material.dart';

import '../../../../core/symbols/rg_symbol.dart';
import '../../../../core/symbols/rg_symbol_view.dart';
import '../../domain/da_criterion.dart';
import '../../domain/da_element.dart';

/// A DA in FIG notation, as coaches write it: the base symbol(s), then the
/// criteria in brackets. Check [canShow] first; a part without a symbol
/// would make the line misleading.
class DaSymbols extends StatelessWidget {
  const DaSymbols(this.element, {super.key, this.size = 20, this.color});

  final DaElement element;
  final double size;
  final Color? color;

  /// Whether every base of [element] has a symbol.
  static bool canShow(DaElement element) =>
      element.base.symbol != null &&
      (element.secondBase == null || element.secondBase!.symbol != null);

  @override
  Widget build(BuildContext context) {
    final colour = color ?? IconTheme.of(context).color!;
    final bases = [element.base.symbol!, ?element.secondBase?.symbol];
    final criteria = [
      for (final criterion in DaCriterion.tableOrder)
        if (element.criteria.contains(criterion)) criterion.symbol,
    ];
    Widget symbol(RgSymbol s) => RgSymbolView(s, size: size, color: colour);
    Widget bracket(String text) => Text(
      text,
      style: TextStyle(fontSize: size, height: 1, color: colour),
    );
    return Semantics(
      label: [
        for (final s in [...bases, ...criteria]) s.description,
      ].join(', '),
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: size * 0.2,
        runSpacing: size * 0.2,
        children: [
          ...bases.map(symbol),
          if (criteria.isNotEmpty) ...[
            bracket('('),
            ...criteria.map(symbol),
            bracket(')'),
          ],
        ],
      ),
    );
  }
}
