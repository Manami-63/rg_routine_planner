import 'package:just_audio/just_audio.dart';

/// Plays one music file. Wraps the audio package so widgets and tests do
/// not depend on it.
abstract interface class MusicPlayer {
  /// Loads the file at [path]; returns its duration if known.
  Future<Duration?> load(String path);

  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);

  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;

  Duration get position;
  bool get playing;

  Future<void> dispose();
}

class JustAudioMusicPlayer implements MusicPlayer {
  final _player = AudioPlayer();

  @override
  Future<Duration?> load(String path) => _player.setFilePath(path);

  @override
  Future<void> play() async {
    // Starting again after the end plays from the beginning.
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    // Not awaited: `play` only completes when playback stops.
    _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<bool> get playingStream => _player.playerStateStream.map(
    (s) => s.playing && s.processingState != ProcessingState.completed,
  );

  @override
  Duration get position => _player.position;

  @override
  bool get playing => _player.playing;

  @override
  Future<void> dispose() => _player.dispose();
}
