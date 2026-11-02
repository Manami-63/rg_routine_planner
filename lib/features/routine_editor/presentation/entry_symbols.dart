import 'package:flutter/widgets.dart';

import '../../da_calculator/presentation/widgets/da_symbols.dart';
import '../../db_calculator/presentation/widgets/db_symbol.dart';
import '../../db_calculator/presentation/widgets/risk_symbols.dart';
import '../domain/routine_timeline.dart';

/// [entry] in FIG notation, [size] high, or `null` when it has no symbols.
Widget? entrySymbols(TimelineEntry entry, {required double size}) {
  if (entry.db?.symbolPath case final path?) {
    return DbSymbol(
      path,
      label: entry.name,
      cycles: entry.dbCycles,
      size: size,
    );
  }
  if (entry.da case final da? when DaSymbols.canShow(da)) {
    return DaSymbols(da, size: size);
  }
  if (entry.risk case final risk? when RiskSymbols.canShow(risk)) {
    return RiskSymbols(risk, size: size);
  }
  return null;
}
