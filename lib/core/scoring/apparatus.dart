/// What the gymnast performs the routine with.
enum Apparatus {
  freehand('Freehand'),
  rope('Rope'),
  hoop('Hoop'),
  ball('Ball'),
  clubs('Clubs'),
  ribbon('Ribbon');

  const Apparatus(this.label);

  final String label;

  /// Freehand routines have no apparatus, so no risks and no DA.
  bool get hasApparatus => this != freehand;

  /// The apparatus stored under [name], or `null` if none or unknown.
  static Apparatus? fromName(String? name) {
    for (final apparatus in values) {
      if (apparatus.name == name) return apparatus;
    }
    return null;
  }
}
