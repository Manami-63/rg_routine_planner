import 'package:file_picker/file_picker.dart';

import '../domain/routine_music.dart';

/// A music file the user chose.
typedef PickedMusic = ({String path, String name});

/// Lets the user choose a music file.
abstract interface class MusicPicker {
  /// The chosen file, or `null` if the user cancelled.
  Future<PickedMusic?> pick();
}

/// Uses the system file picker (the Files app on iOS).
class FilePickerMusicPicker implements MusicPicker {
  const FilePickerMusicPicker();

  @override
  Future<PickedMusic?> pick() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: RoutineMusic.extensions,
    );
    final path = file?.path;
    if (file == null || path == null) return null;
    return (path: path, name: file.name);
  }
}
