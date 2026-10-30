import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// The short intro video (`assets/videos/intro.mp4`): plays muted and on a
/// loop; a tap pauses or plays it. Shows an icon instead while the video
/// is missing or cannot play.
class IntroVideo extends StatefulWidget {
  const IntroVideo({super.key});

  static const asset = 'assets/videos/intro.mp4';

  @override
  State<IntroVideo> createState() => _IntroVideoState();
}

class _IntroVideoState extends State<IntroVideo> {
  // Mixes with other audio so it never stops the user's own music.
  final _controller = VideoPlayerController.asset(
    IntroVideo.asset,
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(0);
      await _controller.setLooping(true);
      await _controller.play();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_failed) {
      return Center(
        child: Icon(Icons.sports_gymnastics, size: 96, color: colors.primary),
      );
    }
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Semantics(
            button: true,
            label: 'Intro video. Tap to pause or play.',
            child: GestureDetector(
              onTap: _toggle,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VideoPlayer(_controller),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, value, _) => value.isPlaying
                        ? const SizedBox.shrink()
                        : const Center(
                            child: Icon(
                              Icons.play_circle,
                              size: 64,
                              color: Colors.white70,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
