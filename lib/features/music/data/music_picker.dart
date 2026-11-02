import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../domain/routine_music.dart';

/// A music file the user chose.
typedef PickedMusic = ({String path, String name});

/// Lets the user choose a music file.
abstract interface class MusicPicker {
  /// The chosen file, or `null` if the user cancelled.
  Future<PickedMusic?> pick();
}

/// Uses the system file picker (the Files app on iOS). It may return a file
/// of another type: callers check it with `RoutineMusic.accepts`.
class FilePickerMusicPicker implements MusicPicker {
  const FilePickerMusicPicker();

  @override
  Future<PickedMusic?> pick() async {
    // Android turns extensions into media types that miss files: .m4a asks
    // for audio/mp4a-latm, but .m4a files are stored as audio/mp4 and show
    // greyed out. So it offers all audio there.
    final android = defaultTargetPlatform == TargetPlatform.android;
    final file = await FilePicker.pickFile(
      type: android ? FileType.audio : FileType.custom,
      allowedExtensions: android ? null : RoutineMusic.extensions,
    );
    final path = file?.path;
    if (file == null || path == null) return null;
    return (path: path, name: file.name);
  }
}
