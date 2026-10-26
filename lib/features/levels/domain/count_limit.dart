/// How a count compares with a [CountLimit].
enum CountStatus { noLimit, belowMinimum, withinLimits, aboveMaximum }

/// An optional minimum and/or maximum number of items, e.g. "2 to 4 DB".
///
/// `null` means "no requirement" on that side.
class CountLimit {
  const CountLimit({this.min, this.max});

  static const none = CountLimit();

  final int? min;
  final int? max;

  bool get isSet => min != null || max != null;

  /// A limit is valid when the minimum does not exceed the maximum.
  bool get isValid {
    final min = this.min, max = this.max;
    return min == null || max == null || min <= max;
  }

  CountLimit withMin(int? value) => CountLimit(min: value, max: max);

  CountLimit withMax(int? value) => CountLimit(min: min, max: value);

  CountStatus statusOf(int count) {
    final min = this.min, max = this.max;
    if (!isSet) return CountStatus.noLimit;
    if (min != null && count < min) return CountStatus.belowMinimum;
    if (max != null && count > max) return CountStatus.aboveMaximum;
    return CountStatus.withinLimits;
  }

  @override
  bool operator ==(Object other) =>
      other is CountLimit && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'CountLimit($min..$max)';
}
