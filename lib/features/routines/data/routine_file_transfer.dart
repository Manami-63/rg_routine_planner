import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
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

  /// Calls [handler] with the path of each routine file opened from another
  /// app, including one that launched this app.
  void onFileOpened(void Function(String path) handler);

  /// The contents of an opened file at [path], which is then removed.
  Future<String> readOpened(String path);
}

/// Uses the system share sheet and file picker.
class SystemRoutineFileTransfer implements RoutineFileTransfer {
  const SystemRoutineFileTransfer();

  /// Far above a routine with its music; files come from other people.
  static const maxBytes = 100 * 1024 * 1024;

  /// Implemented in `AppDelegate.swift` and `MainActivity.kt`.
  static const _opened = MethodChannel('rg_routine_planner/opened_files');

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
    return _read(File(path));
  }

  Future<String> _read(File file) async {
    if (await file.length() > maxBytes) {
      throw const InvalidRoutineFileException();
    }
    return file.readAsString();
  }

  @override
  void onFileOpened(void Function(String path) handler) {
    Future<void> takePending() async {
      final path = await _opened.invokeMethod<String>('takePending');
      if (path != null) handler(path);
    }

    _opened.setMethodCallHandler((_) => takePending());
    takePending().catchError(
      (_) {},
      // Platforms without the channel (desktop, tests).
      test: (error) => error is MissingPluginException,
    );
  }

  @override
  Future<String> readOpened(String path) async {
    final file = File(path);
    try {
      return await _read(file);
    } finally {
      try {
        await file.delete();
      } on FileSystemException {
        // A leftover file only wastes space.
      }
    }
  }
}
