import 'package:flutter/material.dart';

import '../../../../core/symbols/path_symbol_view.dart';

/// A DB's FIG symbol, followed by a Fouetté's [cycles] as coaches write
/// them, e.g. "2121".
class DbSymbol extends StatelessWidget {
  const DbSymbol(
    this.path, {
    super.key,
    required this.label,
    this.cycles,
    this.size = 24,
  });

  final String path;
  final String label;
  final String? cycles;
  final double size;

  @override
  Widget build(BuildContext context) {
    final symbol = PathSymbolView(path, label: label, size: size);
    final cycles = this.cycles;
    if (cycles == null) return symbol;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        symbol,
        SizedBox(width: size * 0.2),
        Text(
          cycles,
          style: TextStyle(fontSize: size * 0.8, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
