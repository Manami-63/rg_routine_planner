/// The music of a routine: a file the app keeps its own copy of.
class RoutineMusic {
  /// The audio file types the app accepts.
  static const extensions = ['mp3', 'm4a', 'aac', 'wav'];

  /// Whether a file called [name] is one of the accepted [extensions].
  static bool accepts(String name) {
    final dot = name.lastIndexOf('.');
    return dot >= 0 &&
        extensions.contains(name.substring(dot + 1).toLowerCase());
  }

  const RoutineMusic({required this.fileName, required this.title});

  /// Name of the app's copy in its music folder (not a full path: the
  /// folder's location can change, e.g. when iOS updates the app).
  final String fileName;

  /// What the user sees: the name of the file they chose.
  final String title;

  @override
  bool operator ==(Object other) =>
      other is RoutineMusic &&
      other.fileName == fileName &&
      other.title == title;

  @override
  int get hashCode => Object.hash(fileName, title);
}
