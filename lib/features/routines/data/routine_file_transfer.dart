import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/routine_file.dart';

/// Sends routine files to other apps and reads them back.
///
/// Files go line by line ([RoutineFile]: a backup has one routine per
/// line), so a backup with music is never held in memory at once.
abstract interface class RoutineFileTransfer {
  /// Offers the [lines] as a file called [fileName]. [origin] is where the
  /// share sheet points on tablets. [lines] is read as it is written, so
  /// it can load one routine at a time.
  Future<void> share({
    required String fileName,
    required Stream<String> lines,
    required Rect origin,
  });

  /// The lines of the file the user chose, or `null` if they cancelled.
  Future<Stream<String>?> pick();

  /// Calls [handler] with the path of each routine file opened from another
  /// app, including one that launched this app.
  void onFileOpened(void Function(String path) handler);

  /// The lines of an opened file at [path], which is removed once read.
  Stream<String> readOpened(String path);
}

/// Uses the system share sheet and file picker.
class SystemRoutineFileTransfer implements RoutineFileTransfer {
  const SystemRoutineFileTransfer();

  /// Far above a backup of many routines with their music; files can come
  /// from other people.
  static const maxBytes = 1024 * 1024 * 1024;

  /// Implemented in `AppDelegate.swift` and `MainActivity.kt`.
  static const _opened = MethodChannel('rg_routine_planner/opened_files');

  @override
  Future<void> share({
    required String fileName,
    required Stream<String> lines,
    required Rect origin,
  }) async {
    final folder = await getTemporaryDirectory();
    final file = File(p.join(folder.path, fileName));
    final sink = file.openWrite();
    try {
      await for (final line in lines) {
        sink.writeln(line);
        // Written out before the next routine (and its music) is loaded.
        await sink.flush();
      }
    } finally {
      await sink.close();
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        sharePositionOrigin: origin,
      ),
    );
  }

  // Any file type: an extension only this app knows cannot be filtered on
  // iOS without registering it. `RoutineFile` checks the contents.
  @override
  Future<Stream<String>?> pick() async {
    final path = (await FilePicker.pickFile(type: FileType.any))?.path;
    if (path == null) return null;
    return _lines(File(path));
  }

  Stream<String> _lines(File file) async* {
    if (await file.length() > maxBytes) {
      throw const InvalidRoutineFileException();
    }
    yield* file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
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
  Stream<String> readOpened(String path) async* {
    final file = File(path);
    try {
      yield* _lines(file);
    } finally {
      try {
        await file.delete();
      } on FileSystemException {
        // A leftover file only wastes space.
      }
    }
  }
}
