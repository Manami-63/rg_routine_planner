import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/routine_file.dart';

/// Sends routine files to other apps and reads them back.
abstract interface class RoutineFileTransfer {
  /// Offers [contents] as a file called [fileName]. [origin] is where the
  /// share sheet points on tablets.
  Future<void> share({
    required String fileName,
    required String contents,
    required Rect origin,
  });

  /// The contents of the file the user chose, or `null` if they cancelled.
  Future<String?> pick();
}

/// Uses the system share sheet and file picker.
class SystemRoutineFileTransfer implements RoutineFileTransfer {
  const SystemRoutineFileTransfer();

  /// Far above a routine with its music; files come from other people.
  static const maxBytes = 100 * 1024 * 1024;

  @override
  Future<void> share({
    required String fileName,
    required String contents,
    required Rect origin,
  }) async {
    final folder = await getTemporaryDirectory();
    final file = File(p.join(folder.path, fileName));
    await file.writeAsString(contents);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        sharePositionOrigin: origin,
      ),
    );
  }

  // Any file type: an extension only this app knows cannot be filtered on
  // iOS without registering it. `RoutineFile.decode` checks the contents.
  @override
  Future<String?> pick() async {
    final path = (await FilePicker.pickFile(type: FileType.any))?.path;
    if (path == null) return null;
    final file = File(path);
    if (await file.length() > maxBytes) {
      throw const InvalidRoutineFileException();
    }
    return file.readAsString();
  }
}
