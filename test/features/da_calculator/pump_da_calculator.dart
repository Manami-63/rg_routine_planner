import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/da_calculator_providers.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/da_calculator_screen.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';

import '../db_calculator/pump_db_calculator.dart';
import '../db_calculator/test_data.dart';
import '../routines/fake_routine_repository.dart';
import 'test_data.dart';

/// Pumps the DA calculator for [routine] (default: an empty Hoop routine)
/// with fake catalogue and routine repositories. Returns the routine
/// repository.
Future<FakeRoutineRepository> pumpDaCalculator(
  WidgetTester tester, {
  FakeDaCatalogueRepository? catalogue,
  Routine? routine,
}) async {
  // A tall surface so the whole scroll view and sheets are built without
  // scrolling.
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final routines = FakeRoutineRepository([
    routine ?? emptyTestRoutine().withApparatus(Apparatus.hoop),
  ]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dbCatalogueRepositoryProvider.overrideWithValue(
          FakeDbCatalogueRepository(),
        ),
        daCatalogueRepositoryProvider.overrideWithValue(
          catalogue ?? FakeDaCatalogueRepository(),
        ),
        routineRepositoryProvider.overrideWithValue(routines),
      ],
      child: const MaterialApp(
        home: DaCalculatorScreen(routineId: testRoutineId),
      ),
    ),
  );
  // Let the routine and catalogue futures complete.
  await tester.pump();
  await tester.pump();
  return routines;
}

ProviderContainer daContainerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(DaCalculatorScreen)));
