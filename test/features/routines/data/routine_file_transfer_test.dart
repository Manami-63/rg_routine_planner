import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rg_routine_planner/features/routines/data/routine_file_transfer.dart';

void main() {
  late Directory folder;

  setUp(() => folder = Directory.systemTemp.createTempSync('routine_files'));
  tearDown(() => folder.deleteSync(recursive: true));

  test('an opened file is read line by line, then removed', () async {
    final file = File(p.join(folder.path, 'backup.rgroutine'))
      // A long line, like a routine with its music.
      ..writeAsStringSync('header\n${'x' * 200000}\nlast\n');

    final lines = await const SystemRoutineFileTransfer()
        .readOpened(file.path)
        .toList();

    expect(lines.map((line) => line.length), [6, 200000, 4]);
    expect(file.existsSync(), isFalse);
  });

  test('an opened file is removed even when not read to the end', () async {
    final file = File(p.join(folder.path, 'a.rgroutine'))
      ..writeAsStringSync('first\nsecond\n');

    final first = await const SystemRoutineFileTransfer()
        .readOpened(file.path)
        .first;

    expect(first, 'first');
    expect(file.existsSync(), isFalse);
  });
}
