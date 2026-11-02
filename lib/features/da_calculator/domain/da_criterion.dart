import '../../../core/symbols/rg_symbol.dart';

/// A criterion performed during a DA base (FIG CoP 2025-2028 #5.4.3, and
/// #7.3 for the Rope-specific ones).
///
/// Which criteria are available depends on the base (see `DaBase`). Stored
/// by [name], so renaming a value needs a migration.
enum DaCriterion {
  outsideVisualField('Outside the visual field', 'Outside visual field'),
  withoutHands('Without the help of the hands', 'Without hands'),
  underLeg('Under the leg/legs', 'Under leg'),
  positionOnFloor('Position on the floor', 'On floor'),
  fullBodyWave('Full body wave', 'Wave'),
  db('During a DB', 'DB'),
  rotation('Rotation (min. 360°)', 'Rotation'),

  // Rope only (Junior, #7.3).
  ropeDoubleRotation(
    'Double (or more) rotation of the Rope',
    'Double rotation',
    isRopeSpecific: true,
  ),
  ropeBackward('Rope turning backward', 'Backward', isRopeSpecific: true),
  ropeCrossedArms('Crossed arms', 'Crossed arms', isRopeSpecific: true);

  const DaCriterion(this.label, this.shortLabel, {this.isRopeSpecific = false});

  /// Name in the builder, e.g. "Outside the visual field".
  final String label;

  /// Name in a DA summary, e.g. "Outside visual field".
  final String shortLabel;

  final bool isRopeSpecific;

  /// The order of the DA tables (#5.8-5.11, #7.3), which FIG notation
  /// follows too.
  static const tableOrder = [
    outsideVisualField,
    withoutHands,
    underLeg,
    rotation,
    positionOnFloor,
    fullBodyWave,
    db,
    ropeDoubleRotation,
    ropeBackward,
    ropeCrossedArms,
  ];

  /// Its FIG symbol (#5.4.3, Rope #7.3).
  RgSymbol get symbol => switch (this) {
    outsideVisualField => RgSymbol.outsideVisualField,
    withoutHands => RgSymbol.withoutHands,
    underLeg => RgSymbol.underLeg,
    positionOnFloor => RgSymbol.positionOnFloor,
    fullBodyWave => RgSymbol.fullBodyWave,
    db => RgSymbol.duringDb,
    rotation => RgSymbol.rotation,
    ropeDoubleRotation => RgSymbol.handling,
    ropeBackward => RgSymbol.ropeBackward,
    ropeCrossedArms => RgSymbol.mill,
  };

  /// The criteria stored as comma-separated names in [text]; unknown names
  /// are skipped.
  static Set<DaCriterion> parseAll(String? text) => {
    for (final name in (text ?? '').split(','))
      for (final criterion in values)
        if (criterion.name == name) criterion,
  };

  /// [criteria] as comma-separated names, in declaration order.
  static String formatAll(Set<DaCriterion> criteria) => [
    for (final criterion in values)
      if (criteria.contains(criterion)) criterion.name,
  ].join(',');
}
