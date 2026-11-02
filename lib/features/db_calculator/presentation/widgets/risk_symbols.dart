import 'package:flutter/material.dart';

import '../../../../core/symbols/rg_symbol.dart';
import '../../../../core/symbols/rg_symbol_view.dart';
import '../../domain/risk.dart';

/// A risk in FIG notation, as coaches write it: the throw's criteria, "R"
/// with the rotations, the criteria during them, then the catch's criteria,
/// e.g. "(⊗ ‡) R4 Z". Check [canShow] first; a part without a symbol would
/// make the line misleading.
class RiskSymbols extends StatelessWidget {
  const RiskSymbols(this.risk, {super.key, this.size = 20, this.color});

  final RiskElement risk;
  final double size;
  final Color? color;

  /// Whether every part of [risk] can be shown.
  static bool canShow(RiskElement risk) =>
      !risk.rotation.isUnknown &&
      risk.criteria.every((criterion) => criterion.symbol != null);

  List<RgSymbol> _symbolsOf(RiskPhase phase) => [
    for (final criterion in risk.criteria)
      if (criterion.phase == phase) criterion.symbol!,
  ];

  @override
  Widget build(BuildContext context) {
    final colour = color ?? IconTheme.of(context).color!;
    final throwing = _symbolsOf(RiskPhase.throwing);
    final rotations = _symbolsOf(RiskPhase.rotations);
    final catching = _symbolsOf(RiskPhase.catching);
    Widget symbol(RgSymbol s) => RgSymbolView(s, size: size, color: colour);
    Widget text(String text, {FontWeight? weight}) => Text(
      text,
      style: TextStyle(
        fontSize: size,
        height: 1,
        color: colour,
        fontWeight: weight,
      ),
    );
    // Brackets only group; one symbol needs none.
    List<Widget> group(List<RgSymbol> symbols) => [
      if (symbols.length > 1) text('('),
      ...symbols.map(symbol),
      if (symbols.length > 1) text(')'),
    ];
    return Semantics(
      label: risk.description,
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: size * 0.2,
        runSpacing: size * 0.2,
        children: [
          ...group(throwing),
          text('R${risk.rotation.rotations}', weight: FontWeight.w700),
          ...rotations.map(symbol),
          ...group(catching),
        ],
      ),
    );
  }
}
