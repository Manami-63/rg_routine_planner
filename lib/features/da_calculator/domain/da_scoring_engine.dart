import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/ruleset.dart';
import '../../../core/scoring/score.dart';
import '../../levels/domain/competition_level.dart';
import 'da_base.dart';
import 'da_criterion.dart';
import 'da_element.dart';
import 'da_routine.dart';

/// Caveats attached to a result. The UI decides how to word them.
enum DaScoreNotice {
  /// Values come from a ruleset that is not verified against official rules.
  unofficialRuleset,

  /// Only some rules were applied; others (e.g. the DB criterion, the
  /// execution of bases and criteria) cannot be checked by the app.
  rulesNotValidated,
}

/// Whether an entry is a DA, and if so whether it is valid.
enum DaStatus {
  valid,

  /// Marked on the music, chosen later: holds its place, worth nothing.
  notChosen,

  // Not a DA (does not use one of the counted DA).
  /// Fewer criteria than the base(s) need (#5.1.3, #5.5.4).
  tooFewCriteria,

  /// Its base is for another apparatus than the routine's.
  otherApparatus,

  /// Its base is no longer in the catalogue.
  unknownBase,

  // An attempt that is not valid: counted in order, worth nothing.
  /// The same combination of base(s) and criteria as an earlier DA (#5.6.2).
  repetition,

  /// A 4th (or later) DA with a pre-acrobatic element as "rotation"
  /// (#5.4.7).
  tooManyPreAcrobatic;

  /// Whether it is a DA at all (valid or not), so it takes one of the
  /// counted DA in chronological order (#5.2.1).
  bool get isDa => switch (this) {
    valid || notChosen || repetition || tooManyPreAcrobatic => true,
    tooFewCriteria || otherApparatus || unknownBase => false,
  };
}

class DaScoreResult {
  const DaScoreResult({
    required this.subtotal,
    required this.values,
    required this.statuses,
    required this.counted,
    required this.floorWarnings,
    required this.countLimitApplied,
    required this.ruleset,
    required this.notices,
  });

  /// Total of the counted, valid DA.
  final Score subtotal;

  /// The value of each entry (same positions) as built, valid or not.
  final List<Score> values;

  final List<DaStatus> statuses;

  /// Positions of the entries that count towards [subtotal] or use up a
  /// counted DA (an invalid attempt counts but adds nothing).
  final Set<int> counted;

  /// Positions of DA that are the 4th or later in a row "on the floor"
  /// (#5.4.6). Only a warning: the app cannot see whether the gymnast
  /// leaves the floor in between.
  final Set<int> floorWarnings;

  /// Whether a level limited how many DA count.
  final bool countLimitApplied;

  final RulesetVersion ruleset;
  final Set<DaScoreNotice> notices;

  /// The DA in the routine (valid or not), counted or not.
  int get daCount => statuses.where((s) => s.isDa).length;

  int get countedCount => counted.length;

  bool isCounted(int index) => counted.contains(index);
}

/// How many DA count for a level's [requirements] in a routine with
/// [apparatus]; `null` for no limit. Freehand routines have no DA.
int? daMaxCounted(LevelRequirements? requirements, Apparatus? apparatus) =>
    apparatus == Apparatus.freehand ? 0 : requirements?.da.max;

/// Calculates a DA score for a routine under one specific ruleset.
///
/// The UI only depends on this interface, so a fuller implementation can
/// be swapped in via `daScoringEngineProvider`.
abstract interface class DaScoringEngine {
  RulesetVersion get ruleset;

  /// The criteria that can be chosen for [base], with an optional
  /// [secondBase]: those available for every base (#5.1.3.2).
  Set<DaCriterion> availableCriteria(DaBase base, [DaBase? secondBase]);

  /// How many criteria [element] needs to be a DA.
  int requiredCriteria(DaElement element);

  /// The value of [element] as built, whether or not it is valid.
  Score daValue(DaElement element);

  /// Calculates the subtotal of the first [maxCounted] DA (the level's
  /// maximum; `null` for no limit) of a routine with [apparatus].
  DaScoreResult calculate(
    DaRoutine routine, {
    Apparatus? apparatus,
    int? maxCounted,
  });
}

/// Values DA by their bases and applies the rules the app can see.
///
/// Rules from the FIG Code of Points 2025-2028: criteria per base (#5.1.3,
/// #5.4.2), value (#5.3), chronological count (#5.2.1), identical
/// repetition (#5.6.2) and pre-acrobatic elements (#5.4.7). Results are
/// always marked provisional.
class ProvisionalDaScoringEngine implements DaScoringEngine {
  const ProvisionalDaScoringEngine({required this.ruleset});

  @override
  final RulesetVersion ruleset;

  /// #5.3.2: a 2nd base adds 0.10 to the highest base.
  static const secondBaseBonus = Score.hundredths(10);

  /// #5.4.7: at most 3 DA with a pre-acrobatic element as "rotation".
  static const maxPreAcrobatic = 3;

  /// #5.4.6: at most 3 consecutive DA in a position on the floor; 0.30
  /// penalty for each set of 4 (shown in a warning, never deducted).
  static const maxConsecutiveOnFloor = 3;
  static const onFloorPenalty = Score.hundredths(30);

  @override
  Set<DaCriterion> availableCriteria(DaBase base, [DaBase? secondBase]) =>
      secondBase == null
      ? base.criteria
      : base.criteria.intersection(secondBase.criteria);

  /// #5.1.3: 2 criteria during 1 base; 1 during both of 2 bases.
  @override
  int requiredCriteria(DaElement element) => element.secondBase == null ? 2 : 1;

  /// #5.3: the base value, or the highest base + 0.10 with a 2nd base. A
  /// manual value replaces it.
  @override
  Score daValue(DaElement element) {
    _checkRuleset(element.base.rulesetId, 'Base ${element.base.id}');
    if (element.manualValue case final manual?) return manual;
    final second = element.secondBase;
    if (second == null) return element.base.value;
    _checkRuleset(second.rulesetId, 'Base ${second.id}');
    final highest = element.base.value.compareTo(second.value) >= 0
        ? element.base.value
        : second.value;
    return highest + secondBaseBonus;
  }

  @override
  DaScoreResult calculate(
    DaRoutine routine, {
    Apparatus? apparatus,
    int? maxCounted,
  }) {
    _checkRuleset(routine.rulesetId, 'Routine');
    final elements = routine.elements;
    final values = [for (final element in elements) daValue(element)];

    final statuses = <DaStatus>[];
    var preAcrobatic = 0;
    for (final (i, element) in elements.indexed) {
      final status = _statusOf(element, apparatus);
      if (status != DaStatus.valid || element.manualValue != null) {
        statuses.add(status);
      } else if (_repeatsEarlier(elements, statuses, i)) {
        statuses.add(DaStatus.repetition);
      } else if (element.usesPreAcrobatic && ++preAcrobatic > maxPreAcrobatic) {
        statuses.add(DaStatus.tooManyPreAcrobatic);
      } else {
        statuses.add(DaStatus.valid);
      }
    }

    // The first DA in chronological order count, valid or not.
    final counted = <int>{};
    for (final (i, status) in statuses.indexed) {
      if (!status.isDa) continue;
      if (maxCounted != null && counted.length >= maxCounted) break;
      counted.add(i);
    }

    return DaScoreResult(
      subtotal: counted
          .where((i) => statuses[i] == DaStatus.valid)
          .fold(Score.zero, (sum, i) => sum + values[i]),
      values: List.unmodifiable(values),
      statuses: List.unmodifiable(statuses),
      counted: Set.unmodifiable(counted),
      floorWarnings: Set.unmodifiable(_floorWarnings(elements, statuses)),
      countLimitApplied: maxCounted != null,
      ruleset: ruleset,
      notices: {
        if (!ruleset.isOfficial) DaScoreNotice.unofficialRuleset,
        DaScoreNotice.rulesNotValidated,
      },
    );
  }

  /// The status of [element] on its own, before comparing it with others.
  DaStatus _statusOf(DaElement element, Apparatus? apparatus) {
    if (element.isPending) return DaStatus.notChosen;
    if (element.manualValue != null || element.isCustom) return DaStatus.valid;
    final base = element.base, second = element.secondBase;
    if (base.isUnknown || (second?.isUnknown ?? false)) {
      return DaStatus.unknownBase;
    }
    if (apparatus != null && base.apparatus != apparatus) {
      return DaStatus.otherApparatus;
    }
    final performed = element.criteria.intersection(
      availableCriteria(base, second),
    );
    return performed.length < requiredCriteria(element)
        ? DaStatus.tooFewCriteria
        : DaStatus.valid;
  }

  /// Whether element [index] repeats an earlier DA identically.
  static bool _repeatsEarlier(
    List<DaElement> elements,
    List<DaStatus> statuses,
    int index,
  ) {
    for (var i = 0; i < index; i++) {
      if (statuses[i].isDa && elements[index].isIdenticalTo(elements[i])) {
        return true;
      }
    }
    return false;
  }

  /// DA from the 4th on in a run of consecutive DA on the floor.
  static Set<int> _floorWarnings(
    List<DaElement> elements,
    List<DaStatus> statuses,
  ) {
    final warnings = <int>{};
    var run = 0;
    for (final (i, element) in elements.indexed) {
      if (!statuses[i].isDa) continue;
      if (element.criteria.contains(DaCriterion.positionOnFloor)) {
        if (++run > maxConsecutiveOnFloor) warnings.add(i);
      } else {
        run = 0;
      }
    }
    return warnings;
  }

  void _checkRuleset(String rulesetId, String what) {
    if (rulesetId != ruleset.id) {
      throw ArgumentError.value(
        rulesetId,
        'rulesetId',
        '$what does not match engine ruleset ${ruleset.id}',
      );
    }
  }
}
