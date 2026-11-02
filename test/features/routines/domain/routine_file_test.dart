import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/floor/floor_cell.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_base.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/domain/routine_file.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';

void main() {
  final created = DateTime.utc(2026, 1, 2);
  final now = DateTime.utc(2026, 10, 31);

  Routine decode(String text) =>
      RoutineFile.decode(text, id: 'new', now: now).routine;

  Routine routine({CompetitionLevel? level}) => Routine(
    id: 'r1',
    name: 'Hoop',
    apparatus: Apparatus.hoop,
    level: level,
    notes: 'Start facing the judges',
    music: const RoutineMusic(fileName: 'a.mp3', title: 'Bolero'),
    danceStepTimes: const [Duration(seconds: 30), null],
    danceStepCells: const [FloorCell.centre, null],
    createdAt: created,
    updatedAt: created,
    db: DbRoutine(
      rulesetId: 'test-v1',
      elements: const [
        testJump,
        DbElement.custom(
          name: 'New DB',
          group: DbElementGroup.balance,
          rulesetId: 'test-v1',
        ),
      ],
      elementOptions: [
        const DbElementOptions(
          flatFoot: true,
          seriesCount: 2,
          rotationCycles: '2121',
        ),
        DbElementOptions(manualValue: Score.hundredths(40)),
      ],
      elementTimes: const [Duration(seconds: 5), null],
      elementCells: const [FloorCell.back, null],
      risks: [
        RiskElement(
          rotation: testThreeRotations,
          criteria: const [testCriterionA],
        ),
      ],
      riskTimes: const [Duration(milliseconds: 12300)],
      riskCells: const [FloorCell.front],
    ),
    da: DaRoutine(
      rulesetId: 'test-v1',
      elements: [
        DaElement(
          base: testCatch,
          secondBase: testRoll,
          criteria: {DaCriterion.values.first},
          preAcrobatic: true,
        ),
        DaElement(
          base: const DaBase.custom(name: 'New DA', rulesetId: 'test-v1'),
          manualValue: Score.hundredths(30),
        ),
      ],
      times: const [Duration(seconds: 20), null],
      cells: const [FloorCell.left, null],
    ),
  );

  /// Edits a valid file, to test what happens to a broken one.
  String edited(void Function(Map<String, dynamic> json) edit) {
    final json =
        jsonDecode(RoutineFile.encode(routine())) as Map<String, dynamic>;
    edit(json);
    return jsonEncode(json);
  }

  test('keeps the content and its ids, as a new routine', () {
    final original = routine(level: figSenior);
    final decoded = decode(RoutineFile.encode(original));

    expect(decoded.id, 'new');
    expect(decoded.createdAt, now);
    expect(decoded.updatedAt, now);
    expect(decoded.name, 'Hoop');
    expect(decoded.apparatus, Apparatus.hoop);
    expect(decoded.level?.id, figSenior.id);
    expect(decoded.notes, original.notes);
    expect(decoded.danceStepTimes, original.danceStepTimes);
    expect(decoded.danceStepCells, original.danceStepCells);
    expect(decoded.rulesetId, 'test-v1');

    expect(decoded.db.elements.map((e) => e.id), [testJump.id, 'custom']);
    expect(decoded.db.elements.last, original.db.elements.last);
    expect(decoded.db.elementOptions, original.db.elementOptions);
    expect(decoded.db.elementTimes, original.db.elementTimes);
    expect(decoded.db.elementCells, original.db.elementCells);
    expect(decoded.db.risks.single.rotation.id, testThreeRotations.id);
    expect(decoded.db.risks.single.criteria.single.id, testCriterionA.id);
    expect(decoded.db.riskTimes, original.db.riskTimes);
    expect(decoded.db.riskCells, original.db.riskCells);

    final da = decoded.da.elements;
    expect(da.first.base.id, testCatch.id);
    expect(da.first.secondBase?.id, testRoll.id);
    expect(da.first.criteria, original.da.elements.first.criteria);
    expect(da.first.preAcrobatic, isTrue);
    expect(da.last.base, original.da.elements.last.base);
    expect(da.last.manualValue, Score.hundredths(30));
    expect(decoded.da.times, original.da.times);
    expect(decoded.da.cells, original.da.cells);
  });

  test('leaves the music out unless given it', () {
    final text = RoutineFile.encode(routine());

    expect(text, isNot(contains('Bolero')));
    expect(text, isNot(contains('a.mp3')));
    final decoded = RoutineFile.decode(text, id: 'new', now: now);
    expect(decoded.routine.music, isNull);
    expect(decoded.music, isNull);
  });

  const music = SharedMusic(
    title: 'Bolero',
    extension: 'mp3',
    bytes: [0, 1, 254, 255],
  );

  test('carries music given to it', () {
    final decoded = RoutineFile.decode(
      RoutineFile.encode(routine(), music: music),
      id: 'new',
      now: now,
    );

    expect(decoded.routine.music, isNull);
    expect(decoded.music?.title, 'Bolero');
    expect(decoded.music?.extension, 'mp3');
    expect(decoded.music?.bytes, music.bytes);
  });

  test('rejects music it could not store safely', () {
    String withMusic(void Function(Map<String, dynamic> music) edit) {
      final json = jsonDecode(
        RoutineFile.encode(routine(), music: music),
      ) as Map<String, dynamic>;
      edit(json['music'] as Map<String, dynamic>);
      return jsonEncode(json);
    }

    for (final text in [
      withMusic((m) => m['extension'] = '../../evil'),
      withMusic((m) => m['data'] = 'not base64!'),
      withMusic((m) => m.remove('title')),
    ]) {
      expect(
        () => decode(text),
        throwsA(isA<InvalidRoutineFileException>()),
        reason: text,
      );
    }
  });

  test('keeps a non-FIG level with its numbers', () {
    const level = CompetitionLevel.custom(
      LevelRequirements(
        db: CountLimit(min: 2, max: 6),
        da: CountLimit(max: 12),
        requiredBodyGroups: {DbElementGroup.jump},
        minDanceSteps: 1,
      ),
    );

    expect(decode(RoutineFile.encode(routine(level: level))).level, level);
  });

  test('a routine without apparatus or level stays that way', () {
    final blank = Routine.create(id: 'r', rulesetId: 'test-v1', now: created);
    final decoded = decode(RoutineFile.encode(blank));

    expect(decoded.apparatus, isNull);
    expect(decoded.level, isNull);
    expect(decoded.db.isEmpty, isTrue);
    expect(decoded.da.isEmpty, isTrue);
  });

  test('a cell without a time is dropped', () {
    final text = edited((json) {
      (json['danceSteps'] as List<dynamic>).last['cell'] = 5;
    });

    expect(decode(text).danceStepCells.last, isNull);
  });

  test('a newer format asks for an update', () {
    expect(
      () => decode(edited((json) => json['format'] = 2)),
      throwsA(isA<NewerRoutineFileException>()),
    );
  });

  test('rejects anything that is not a routine file', () {
    final invalid = [
      '',
      'hello',
      '[]',
      '{}',
      '{"app": "other", "format": 1}',
      edited((json) => json.remove('format')),
      edited((json) => json['format'] = 0),
      edited((json) => json.remove('name')),
      edited((json) => json['name'] = 3),
      edited((json) => json['elements'] = 'none'),
      edited((json) => (json['elements'] as List<dynamic>).add(1)),
      edited(
        (json) => (json['danceSteps'] as List<dynamic>).first['timeMs'] = -1,
      ),
      edited(
        (json) => (json['elements'] as List<dynamic>).first['seriesCount'] = 0,
      ),
      edited(
        (json) =>
            (json['elements'] as List<dynamic>).first['rotationCycles'] = '2x',
      ),
      edited((json) => (json['da'] as List<dynamic>).last['manualValue'] = 0.3),
      edited((json) => json['levelId'] = 'custom'),
    ];

    for (final text in invalid) {
      expect(
        () => decode(text),
        throwsA(isA<InvalidRoutineFileException>()),
        reason: text,
      );
    }
  });

  test('file names are safe and never empty', () {
    expect(RoutineFile.fileNameFor('Hoop 2026'), 'Hoop 2026.rgroutine');
    expect(RoutineFile.fileNameFor('a/b:c'), 'a b c.rgroutine');
    expect(RoutineFile.fileNameFor(' / '), 'Routine.rgroutine');
  });
}
