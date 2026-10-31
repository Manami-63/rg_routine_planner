import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../domain/routine_music.dart';

/// The app's own copies of routine music, so a routine keeps its music
/// even if the original file is moved or deleted.
abstract interface class MusicLibrary {
  /// Copies the file at [sourcePath] into the library.
  Future<RoutineMusic> add(String sourcePath, {required String title});

  /// Saves [bytes], audio of type [extension] (e.g. `mp3`), in the library.
  Future<RoutineMusic> addBytes(
    List<int> bytes, {
    required String extension,
    required String title,
  });

  /// The contents of the file of [music].
  Future<List<int>> readBytes(RoutineMusic music);

  /// A separate copy of [music], e.g. for a duplicated routine.
  Future<RoutineMusic> copy(RoutineMusic music);

  /// The full path of [music], or `null` if its file is missing.
  Future<String?> pathOf(RoutineMusic music);

  /// Deletes the file of [music], if it exists.
  Future<void> delete(RoutineMusic music);
}

/// Stores music files in a folder on the device.
class FileMusicLibrary implements MusicLibrary {
  /// [folder] is looked up when first needed (e.g. via `path_provider`).
  FileMusicLibrary(this.folder);

  final Future<Directory> Function() folder;

  Future<File> _file(String fileName) async =>
      File(p.join((await folder()).path, fileName));

  @override
  Future<RoutineMusic> add(String sourcePath, {required String title}) =>
      _copyFrom(sourcePath, title);

  @override
  Future<RoutineMusic> addBytes(
    List<int> bytes, {
    required String extension,
    required String title,
  }) async {
    final dir = await folder();
    await dir.create(recursive: true);
    final fileName = '${const Uuid().v4()}.$extension';
    await File(p.join(dir.path, fileName)).writeAsBytes(bytes);
    return RoutineMusic(fileName: fileName, title: title);
  }

  @override
  Future<List<int>> readBytes(RoutineMusic music) async =>
      (await _file(music.fileName)).readAsBytes();

  @override
  Future<RoutineMusic> copy(RoutineMusic music) async =>
      _copyFrom((await _file(music.fileName)).path, music.title);

  Future<RoutineMusic> _copyFrom(String sourcePath, String title) async {
    final dir = await folder();
    await dir.create(recursive: true);
    // A new name each time, so routines never share a file.
    final fileName =
        '${const Uuid().v4()}${p.extension(sourcePath).toLowerCase()}';
    await File(sourcePath).copy(p.join(dir.path, fileName));
    return RoutineMusic(fileName: fileName, title: title);
  }

  @override
  Future<String?> pathOf(RoutineMusic music) async {
    final file = await _file(music.fileName);
    return await file.exists() ? file.path : null;
  }

  @override
  Future<void> delete(RoutineMusic music) async {
    final file = await _file(music.fileName);
    if (await file.exists()) await file.delete();
  }
}
