/// One of 9 equal parts (3 x 3) of the 13 x 13 m floor area (CoP #7.1).
///
/// Laid out as in the CoP pictures (#9.2.1): the front, where the judges
/// sit, at the bottom. Numbered 1 (back left) to 9 (front right).
///
/// The corner cells and the centre cell stand for the 5 zones the gymnast
/// must visit (#9.2, picture #9.2.1.A: a quarter circle in each corner and
/// a circle in the centre, each about a third of the floor across).
enum FloorCell {
  backLeft(0, 0, 'Back left'),
  back(0, 1, 'Back'),
  backRight(0, 2, 'Back right'),
  left(1, 0, 'Left'),
  centre(1, 1, 'Centre'),
  right(1, 2, 'Right'),
  frontLeft(2, 0, 'Front left'),
  front(2, 1, 'Front'),
  frontRight(2, 2, 'Front right');

  const FloorCell(this.row, this.column, this.label);

  /// 0 (back) to 2 (front).
  final int row;

  /// 0 (left) to 2 (right).
  final int column;
  final String label;

  /// 1 (back left) to 9 (front right), reading like text.
  int get number => row * 3 + column + 1;

  /// The cell numbered [number], or `null` (also for `null`).
  static FloorCell? fromNumber(int? number) =>
      number != null && number >= 1 && number <= 9 ? values[number - 1] : null;

  static FloorCell at(int row, int column) => values[row * 3 + column];

  /// Whether this cell stands for one of the 5 zones (#9.2.1.A).
  bool get isZone => this == centre || (row != 1 && column != 1);

  /// The zones, in cell order.
  static final zones = [
    for (final cell in values)
      if (cell.isZone) cell,
  ];

  /// The other cells a gymnast crosses when travelling in a straight line
  /// from the middle of this cell to the middle of [to] (not counting the
  /// two ends). Touching only a corner point does not count.
  ///
  /// Only a guess: gymnasts often travel in curves (#9.3).
  Set<FloorCell> crossedTo(FloorCell to) {
    // Sample the segment; a point exactly on a cell boundary is avoided by
    // sampling between steps.
    const steps = 600;
    final crossed = <FloorCell>{};
    for (var k = 0; k < steps; k++) {
      final t = (k + 0.5) / steps;
      final y = row + 0.5 + (to.row - row) * t;
      final x = column + 0.5 + (to.column - column) * t;
      crossed.add(at(y.floor().clamp(0, 2), x.floor().clamp(0, 2)));
    }
    return crossed
      ..remove(this)
      ..remove(to);
  }
}
