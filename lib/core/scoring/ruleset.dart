/// Identifies the set of rules and element values a calculation is based on.
///
/// Every element, routine and scoring engine refers to a ruleset, so data
/// from different rule versions (sample data, a future verified Code of
/// Points edition, ...) can never be silently mixed. Shared by DB and DA.
class RulesetVersion {
  const RulesetVersion({
    required this.id,
    required this.label,
    required this.isOfficial,
    this.detail,
  });

  /// Stable identifier, suitable for persistence (e.g. `fig-2025`).
  final String id;

  /// Human-readable name shown in the UI.
  final String label;

  /// Whether the values have been verified against official published rules.
  /// The UI warns users whenever this is `false`.
  final bool isOfficial;

  /// What is (and is not) official in an unofficial ruleset, shown in the
  /// warning banner. `null` uses a generic message.
  final String? detail;

  @override
  bool operator ==(Object other) =>
      other is RulesetVersion &&
      other.id == id &&
      other.label == label &&
      other.isOfficial == isOfficial &&
      other.detail == detail;

  @override
  int get hashCode => Object.hash(id, label, isOfficial, detail);

  @override
  String toString() => 'RulesetVersion($id)';
}
