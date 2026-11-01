import 'dart:ui';

import 'package:rg_routine_planner/features/routines/data/routine_file_transfer.dart';

/// Records what is shared and returns [next] once when picking.
class FakeRoutineFileTransfer implements RoutineFileTransfer {
  String? sharedFileName;
  String? sharedContents;
  String? next;
  Object? shareError;

  @override
  Future<void> share({
    required String fileName,
    required String contents,
    required Rect origin,
  }) async {
    if (shareError case final error?) throw error;
    sharedFileName = fileName;
    sharedContents = contents;
  }

  @override
  Future<String?> pick() async {
    final picked = next;
    next = null;
    return picked;
  }

  void Function(String path)? fileOpened;

  /// Contents of opened files, by path.
  final opened = <String, String>{};

  @override
  void onFileOpened(void Function(String path) handler) => fileOpened = handler;

  @override
  Future<String> readOpened(String path) async => opened.remove(path)!;
}
