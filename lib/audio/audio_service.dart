import 'package:audioplayers/audioplayers.dart';

/// Bronze bell on select, paper rustle on a quiet move, ink splash on
/// capture — per the Phase 4 plan. Every call swallows its own errors:
/// audio is a non-critical enhancement, and platforms/environments
/// without a working audio backend (e.g. a headless test run) must never
/// crash or block the game over a missed sound.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioService() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playSelect() => _play('audio/bell.wav');

  Future<void> playMove() => _play('audio/rustle.wav');

  Future<void> playCapture() => _play('audio/splash.wav');

  Future<void> _play(String assetPath) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // No-op: see class doc.
    }
  }

  void dispose() {
    _player.dispose();
  }
}
