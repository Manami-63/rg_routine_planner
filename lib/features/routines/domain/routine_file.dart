import 'dart:convert';

import '../../../core/floor/floor_cell.dart';
import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/score.dart';
import '../../da_calculator/domain/da_base.dart';
import '../../da_calculator/domain/da_criterion.dart';
import '../../da_calculator/domain/da_element.dart';
import '../../da_calculator/domain/da_routine.dart';
import '../../db_calculator/domain/db_element.dart';
import '../../db_calculator/domain/db_element_options.dart';
import '../../db_calculator/domain/db_routine.dart';
import '../../db_calculator/domain/risk.dart';
import '../../levels/domain/competition_level.dart';
import '../../levels/domain/count_limit.dart';
import '../../music/domain/routine_music.dart';
import 'routine.dart';

/// Thrown when a file is not a readable routine file.
class InvalidRoutineFileException implements Exception {
  const InvalidRoutineFileException();
}

/// Thrown when a routine file comes from a newer version of the app.
class NewerRoutineFileException implements Exception {
  const NewerRoutineFileException();
}

/// A track travelling inside a routine file.
class SharedMusic {
  const SharedMusic({
    required this.title,
    required this.extension,
    required this.bytes,
  });

  final String title;

  /// The audio file type, one of `RoutineMusic.extensions`.
  final String extension;
  final List<int> bytes;
}

/// The routine file people send each other (JSON).
///
/// Like the database, it holds catalogue ids, never values. [decode] gives
/// `.unknown(...)` placeholders that keep those ids; saving the routine and
/// loading it again resolves them from the current catalogue, so values
/// always come from the receiver's app. The sender chooses whether the
/// music goes in (as base64); either way its marked times do, so without
/// it they work once the receiver adds the same track.
abstract final class RoutineFile {
  static const extension = 'rgroutine';

  static const _app = 'rg_routine_planner';
  static const _format = 1;

  /// A safe file name for a routine called [name].
  static String fileNameFor(String name) {
    final safe = name.replaceAll(RegExp(r'[/\\:*?"<>|\x00-\x1F]'), ' ').trim();
    return '${safe.isEmpty ? 'Routine' : safe}.$extension';
  }

  static String encode(Routine routine, {SharedMusic? music}) {
    final db = routine.db;
    final da = routine.da;
    final level = routine.level;
    final custom = (level?.isCustom ?? false) ? level!.requirements : null;
    return jsonEncode({
      'app': _app,
      'format': _format,
      'name': routine.name,
      'rulesetId': routine.rulesetId,
      'apparatus': routine.apparatus?.name,
      'levelId': level?.id,
      if (custom != null)
        'customLevel': {
          'dbMin': custom.db.min,
          'dbMax': custom.db.max,
          'riskMin': custom.risk.min,
          'riskMax': custom.risk.max,
          'daMin': custom.da.min,
          'daMax': custom.da.max,
          'requiredBodyGroups': [
            for (final group in DbElementGroup.requirable)
              if (custom.requiredBodyGroups.contains(group)) group.name,
          ],
          'danceStepsMin': custom.minDanceSteps,
        },
      'notes': routine.notes,
      if (music != null)
        'music': {
          'title': music.title,
          'extension': music.extension,
          'data': base64Encode(music.bytes),
        },
      'danceSteps': [
        for (final (i, time) in routine.danceStepTimes.indexed)
          _timing(time, routine.danceStepCells[i]),
      ],
      'elements': [
        for (final (i, element) in db.elements.indexed)
          {
            'id': element.id,
            if (element.isCustom) ...{
              'customName': element.name,
              'customGroup': element.group.name,
            },
            'flatFoot': db.elementOptions[i].flatFoot,
            'slowTurn': db.elementOptions[i].slowTurn,
            'extraRotations': db.elementOptions[i].extraRotations,
            'seriesCount': db.elementOptions[i].seriesCount,
            'manualValue': db.elementOptions[i].manualValue?.hundredths,
            ..._timing(db.elementTimes[i], db.elementCells[i]),
          },
      ],
      'risks': [
        for (final (i, risk) in db.risks.indexed)
          {
            'rotation': risk.rotation.id,
            'criteria': [for (final c in risk.criteria) c.id],
            ..._timing(db.riskTimes[i], db.riskCells[i]),
          },
      ],
      'da': [
        for (final (i, element) in da.elements.indexed)
          {
            'base': element.base.id,
            'secondBase': element.secondBase?.id,
            'customName': element.isCustom ? element.base.name : null,
            'criteria': DaCriterion.formatAll(element.criteria),
            'preAcrobatic': element.preAcrobatic,
            'manualValue': element.manualValue?.hundredths,
            ..._timing(da.times[i], da.cells[i]),
          },
      ],
    });
  }

  static Map<String, Object?> _timing(Duration? time, FloorCell? cell) => {
    'timeMs': time?.inMilliseconds,
    'cell': cell?.number,
  };

  /// The routine in [text], as a new routine with [id] created [now] and
  /// no music yet, and the music in the file, if any: it has to be stored
  /// before the routine can refer to it.
  ///
  /// Throws [NewerRoutineFileException] or [InvalidRoutineFileException].
  /// Files come from other people, so everything is checked.
  static ({Routine routine, SharedMusic? music}) decode(
    String text, {
    required String id,
    required DateTime now,
  }) {
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      if (json['app'] != _app) throw const InvalidRoutineFileException();
      final format = _count(json['format'], min: 1);
      if (format > _format) throw const NewerRoutineFileException();
      return (routine: _routine(json, id: id, now: now), music: _music(json));
    } on FormatException {
      throw const InvalidRoutineFileException();
    } on TypeError {
      throw const InvalidRoutineFileException();
    }
  }

  static Routine _routine(
    Map<String, dynamic> json, {
    required String id,
    required DateTime now,
  }) {
    final rulesetId = json['rulesetId'] as String;
    final danceSteps = _maps(json['danceSteps']);
    final elements = _maps(json['elements']);
    final risks = _maps(json['risks']);
    final das = _maps(json['da']);

    DaBase base(String id) => DaBase.unknown(id: id, rulesetId: rulesetId);

    return Routine(
      id: id,
      name: json['name'] as String,
      apparatus: Apparatus.fromName(json['apparatus'] as String?),
      level: _level(json),
      notes: json['notes'] as String,
      danceStepTimes: [for (final s in danceSteps) _time(s)],
      danceStepCells: [for (final s in danceSteps) _cell(s)],
      createdAt: now,
      updatedAt: now,
      db: DbRoutine(
        rulesetId: rulesetId,
        elements: [
          for (final e in elements)
            if (e['id'] == DbElement.customId)
              DbElement.custom(
                name: e['customName'] as String,
                group: DbElementGroup.values.firstWhere(
                  (g) => g.name == e['customGroup'],
                  orElse: () => DbElementGroup.unknown,
                ),
                rulesetId: rulesetId,
              )
            else
              DbElement.unknown(id: e['id'] as String, rulesetId: rulesetId),
        ],
        elementOptions: [
          for (final e in elements)
            DbElementOptions(
              flatFoot: e['flatFoot'] as bool,
              slowTurn: e['slowTurn'] as bool,
              extraRotations: _count(e['extraRotations']),
              seriesCount: _count(e['seriesCount'], min: 1),
              manualValue: _score(e['manualValue']),
            ),
        ],
        elementTimes: [for (final e in elements) _time(e)],
        elementCells: [for (final e in elements) _cell(e)],
        risks: [
          for (final r in risks)
            RiskElement(
              rotation: RiskRotationOption.unknown(
                id: r['rotation'] as String,
                rulesetId: rulesetId,
              ),
              criteria: [
                for (final c in r['criteria'] as List<dynamic>)
                  RiskCriterion.unknown(id: c as String, rulesetId: rulesetId),
              ],
            ),
        ],
        riskTimes: [for (final r in risks) _time(r)],
        riskCells: [for (final r in risks) _cell(r)],
      ),
      da: DaRoutine(
        rulesetId: rulesetId,
        elements: [
          for (final a in das)
            DaElement(
              base: a['base'] == DaBase.customId
                  ? DaBase.custom(
                      name: a['customName'] as String,
                      rulesetId: rulesetId,
                    )
                  : base(a['base'] as String),
              secondBase: switch (a['secondBase'] as String?) {
                final id? => base(id),
                null => null,
              },
              criteria: DaCriterion.parseAll(a['criteria'] as String),
              preAcrobatic: a['preAcrobatic'] as bool,
              manualValue: _score(a['manualValue']),
            ),
        ],
        times: [for (final a in das) _time(a)],
        cells: [for (final a in das) _cell(a)],
      ),
    );
  }

  static SharedMusic? _music(Map<String, dynamic> json) {
    final music = json['music'] as Map<String, dynamic>?;
    if (music == null) return null;
    final extension = music['extension'] as String;
    // It becomes part of a file name in the app's folder.
    if (!RoutineMusic.extensions.contains(extension)) {
      throw const InvalidRoutineFileException();
    }
    return SharedMusic(
      title: music['title'] as String,
      extension: extension,
      bytes: base64Decode(music['data'] as String),
    );
  }

  static CompetitionLevel? _level(Map<String, dynamic> json) {
    final id = json['levelId'] as String?;
    if (id == null) return null;
    if (id != CompetitionLevel.customId) {
      // Resolved from the presets on load, like a catalogue id.
      return CompetitionLevel(id: id, label: 'Unknown level', isFig: false);
    }
    final custom = json['customLevel'] as Map<String, dynamic>;
    final requirements = LevelRequirements(
      db: _limit(custom['dbMin'], custom['dbMax']),
      risk: _limit(custom['riskMin'], custom['riskMax']),
      da: _limit(custom['daMin'], custom['daMax']),
      requiredBodyGroups: {
        for (final name in custom['requiredBodyGroups'] as List<dynamic>)
          for (final group in DbElementGroup.requirable)
            if (group.name == name) group,
      },
      minDanceSteps: _optionalCount(custom['danceStepsMin']),
    );
    if (!requirements.isValid) throw const InvalidRoutineFileException();
    return CompetitionLevel.custom(requirements);
  }

  static CountLimit _limit(Object? min, Object? max) =>
      CountLimit(min: _optionalCount(min), max: _optionalCount(max));

  static List<Map<String, dynamic>> _maps(Object? list) => [
    for (final item in list! as List<dynamic>) item as Map<String, dynamic>,
  ];

  static int _count(Object? value, {int min = 0}) {
    final count = value! as int;
    if (count < min) throw const InvalidRoutineFileException();
    return count;
  }

  static int? _optionalCount(Object? value) =>
      value == null ? null : _count(value);

  static Score? _score(Object? value) => switch (_optionalCount(value)) {
    final hundredths? => Score.hundredths(hundredths),
    null => null,
  };

  static Duration? _time(Map<String, dynamic> item) =>
      switch (_optionalCount(item['timeMs'])) {
        final ms? => Duration(milliseconds: ms),
        null => null,
      };

  /// Cells are only kept for timed items.
  static FloorCell? _cell(Map<String, dynamic> item) => item['timeMs'] == null
      ? null
      : FloorCell.fromNumber(item['cell'] as int?);
}
