import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../db_calculator/pump_db_calculator.dart';
import '../routines/fake_routine_repository.dart';
import 'test_data.dart';

/// Pumps the routine page on the DA tab for [routine] (default: an empty
/// Hoop routine) with fake catalogue and routine repositories. Returns the
/// routine repository.
Future<FakeRoutineRepository> pumpDaCalculator(
  WidgetTester tester, {
  FakeDaCatalogueRepository? catalogue,
  Routine? routine,
}) => pumpDbCalculator(
  tester,
  daCatalogue: catalogue,
  routine: routine ?? emptyTestRoutine().withApparatus(Apparatus.hoop),
  initialTab: RoutineTab.da,
  // Tall enough for the DA builder sheet too.
  height: 3000,
);

ProviderContainer daContainerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(RoutineScreen)));
