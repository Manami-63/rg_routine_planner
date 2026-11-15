import 'dart:convert';
import 'dart:ui';

import 'package:rg_routine_planner/features/routines/data/routine_file_transfer.dart';

/// Records what is shared and returns [next] once when picking. Contents
/// are the file's text: its lines joined with newlines.
class FakeRoutineFileTransfer implements RoutineFileTransfer {
  String? sharedFileName;
  String? sharedContents;
  String? next;
  Object? shareError;

  /// The lines of [sharedContents].
  List<String> get sharedLines => const LineSplitter().convert(sharedContents!);

  @override
  Future<void> share({
    required String fileName,
    required Stream<String> lines,
    required Rect origin,
  }) async {
    if (shareError case final error?) throw error;
    final written = await lines.toList();
    sharedFileName = fileName;
    sharedContents = written.join('\n');
  }

  @override
  Future<Stream<String>?> pick() async {
    final picked = next;
    next = null;
    return picked == null ? null : _lines(picked);
  }

  void Function(String path)? fileOpened;

  /// Contents of opened files, by path.
  final opened = <String, String>{};

  @override
  void onFileOpened(void Function(String path) handler) => fileOpened = handler;

  @override
  Stream<String> readOpened(String path) => _lines(opened.remove(path)!);

  static Stream<String> _lines(String contents) =>
      Stream.fromIterable(const LineSplitter().convert(contents));
}
