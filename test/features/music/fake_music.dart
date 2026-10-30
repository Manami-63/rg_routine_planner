import 'dart:async';

import 'package:rg_routine_planner/features/music/data/music_library.dart';
import 'package:rg_routine_planner/features/music/data/music_picker.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/music/presentation/music_player.dart';

/// An in-memory music library: file names map to their source paths.
class FakeMusicLibrary implements MusicLibrary {
  FakeMusicLibrary([Map<String, String>? files]) : files = files ?? {};

  final Map<String, String> files;
  var _next = 0;

  @override
  Future<RoutineMusic> add(String sourcePath, {required String title}) async {
    final fileName = 'music-${_next++}.mp3';
    files[fileName] = sourcePath;
    return RoutineMusic(fileName: fileName, title: title);
  }

  @override
  Future<RoutineMusic> copy(RoutineMusic music) async =>
      add(files[music.fileName]!, title: music.title);

  @override
  Future<String?> pathOf(RoutineMusic music) async =>
      files.containsKey(music.fileName) ? '/music/${music.fileName}' : null;

  @override
  Future<void> delete(RoutineMusic music) async => files.remove(music.fileName);
}

/// Returns [next] once, as if the user chose it (`null`: cancelled).
class FakeMusicPicker implements MusicPicker {
  PickedMusic? next;

  @override
  Future<PickedMusic?> pick() async {
    final picked = next;
    next = null;
    return picked;
  }
}

/// A player whose time only moves when a test seeks.
class FakeMusicPlayer implements MusicPlayer {
  FakeMusicPlayer({this.duration = const Duration(seconds: 90)});

  final Duration duration;
  String? loadedPath;
  var disposed = false;

  final _position = StreamController<Duration>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  final _speed = StreamController<double>.broadcast();

  @override
  Duration position = Duration.zero;

  @override
  bool playing = false;

  @override
  double speed = 1;

  @override
  Future<Duration?> load(String path) async {
    loadedPath = path;
    return duration;
  }

  @override
  Future<void> play() async => _playing.add(playing = true);

  @override
  Future<void> pause() async => _playing.add(playing = false);

  @override
  Future<void> seek(Duration to) async => _position.add(position = to);

  @override
  Future<void> setSpeed(double to) async => _speed.add(speed = to);

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Stream<double> get speedStream => _speed.stream;

  @override
  Stream<bool> get playingStream => _playing.stream;

  @override
  Future<void> dispose() async => disposed = true;
}

/// The music fakes used together in widget tests.
class FakeMusic {
  final library = FakeMusicLibrary();
  final picker = FakeMusicPicker();
  final player = FakeMusicPlayer();
}
