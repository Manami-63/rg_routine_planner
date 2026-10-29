import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/music/data/music_library.dart';

void main() {
  late Directory temp;
  late File source;
  late FileMusicLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('music_library_test');
    addTearDown(() => temp.delete(recursive: true));
    source = await File('${temp.path}/Bolero.MP3').writeAsString('tune');
    library = FileMusicLibrary(() async => Directory('${temp.path}/music'));
  });

  test('adds a copy that survives the original being deleted', () async {
    final music = await library.add(source.path, title: 'Bolero');
    await source.delete();

    expect(music.title, 'Bolero');
    expect(music.fileName, endsWith('.mp3'));
    final path = await library.pathOf(music);
    expect(path, startsWith('${temp.path}/music/'));
    expect(await File(path!).readAsString(), 'tune');
  });

  test('copies are separate files', () async {
    final music = await library.add(source.path, title: 'Bolero');
    final copy = await library.copy(music);

    expect(copy.fileName, isNot(music.fileName));
    expect(copy.title, 'Bolero');
    await library.delete(music);
    expect(await library.pathOf(music), isNull);
    expect(await library.pathOf(copy), isNotNull);
  });

  test('deleting a missing file does nothing', () async {
    final music = await library.add(source.path, title: 'Bolero');
    await library.delete(music);

    await library.delete(music);
    expect(await library.pathOf(music), isNull);
  });
}
