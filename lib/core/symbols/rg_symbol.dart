/// The FIG Code of Points 2025-2028 symbols shared across elements: the
/// apparatus technical groups (#3.3), those valid for all apparatus (#3.4)
/// the DA criteria (#5.4.3) and the risk criteria (#4.8, #4.10). Redrawn as vectors by `RgSymbolView`.
///
/// Rope is not here yet, and neither are the apparatus' own marks.
enum RgSymbol {
  // #3.3: on more than one apparatus.
  largeRoll('Large roll', '#3.3', aspect: 1.7),
  rollOnFloor('Roll on the floor or body', '#3.3', aspect: 1.7),
  handling('Handling', '#3.3, #3.4.4', aspect: 1.5),
  passing('Passing through', '#3.3.1, #3.3.4', aspect: 1.5),
  circle('Rotation or small circle', '#3.3.1, #3.3.3'),

  // #3.3.1 Hoop.
  rotationAxis('Rotation around the axis', '#3.3.1'),
  rotationAxisFloor('Rotation on the floor', '#3.3.1', aspect: 1.3),

  highThrowWithRotation('High throw with rotation', '#5.8'),

  // #3.3.2 Ball.
  figureEight('Figure eight', '#3.3.2', aspect: 0.7),
  catchOneHand('Catch with 1 hand', '#3.3.2', aspect: 0.7),
  rebound('Rebound on the floor', '#3.3.2', aspect: 0.9),
  bounces('Bounces', '#3.3.2', aspect: 0.8),

  // #3.3.3 Clubs.
  mill('Mill', '#3.3.3'),
  asymmetry('Asymmetric movements', '#3.3.3'),
  smallThrowTwoClubs('Small throws of 2 unlocked Clubs', '#3.3.3', aspect: 1.5),
  smallThrowLockedClubs('Small throw of 2 locked Clubs', '#3.3.3', aspect: 1.8),
  smallCirclesBothClubs('Small circles with both Clubs', '#3.3.3', aspect: 1.3),

  // #3.3.4 Ribbon.
  spiral('Spirals', '#3.3.4', aspect: 0.6),
  swordsman('Swordsman', '#3.3.4', aspect: 0.7),
  snake('Snakes', '#3.3.4', aspect: 0.5),
  boomerang('Boomerang', '#3.3.4', aspect: 1.5),
  echappe('Echappé', '#3.3.4', aspect: 1.3),
  highThrowFromSliding('High throw from sliding', '#5.11', aspect: 0.8),

  // #3.4 All apparatus.
  highThrow('High throw', '#3.4.1'),
  highThrowTwoClubs('High throw of 2 unlocked Clubs', '#3.4.1'),
  catchHighThrow('Catch from a high throw', '#3.4.1', aspect: 0.7),
  catchTwoClubs('Simultaneous catch of 2 Clubs', '#3.4.1', aspect: 0.7),
  smallThrow('Small throw and catch', '#3.4.2', aspect: 1.3),
  underFlightJump('Jump under the flight', '#3.4.3'),
  underFlightBalance('Balance under the flight', '#3.4.3'),
  underFlightRotation('Rotation under the flight', '#3.4.3'),

  // #5.4.3 DA criteria.
  outsideVisualField('Outside the visual field', '#5.4.3'),
  withoutHands('Without the help of the hands', '#5.4.3'),
  underLeg('Under the leg', '#5.4.3'),
  positionOnFloor('Position on the floor', '#5.4.3'),
  fullBodyWave('Full body wave', '#5.4.3'),
  duringDb('During a DB', '#5.4.3', aspect: 1.3),
  rotation('Rotation', '#5.4.3', aspect: 0.7),

  // #4.8, #4.10 Risk criteria.
  changeOfAxisOrLevel('Change of rotation axis or level', '#4.8.1'),
  series('Series', '#4.8.1'),
  directRebound('Direct rebound on the body', '#4.10.1', aspect: 0.9),
  catchWithRoll('Direct catch with rolling', '#4.10.1', aspect: 1.7),
  catchWithRotation('Direct catch with rotation', '#4.10.1');

  const RgSymbol(this.description, this.reference, {this.aspect = 1});

  /// What it stands for, shown beside the symbol and read by screen readers.
  final String description;

  /// Where it is in the Code of Points.
  final String reference;

  /// Its width as a fraction of its height.
  final double aspect;
}
