import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _effectsPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _areEffectsEnabled = true;
  double _volume = 0.5; // 50% default volume

  bool get isMusicEnabled => _isMusicEnabled;
  bool get areEffectsEnabled => _areEffectsEnabled;
  double get volume => _volume;

  Future<void> init() async {
    // Set background music to loop
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundPlayer.setVolume(_volume);
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      final state = _backgroundPlayer.state;
      if (state == PlayerState.paused) {
        await _backgroundPlayer.resume();
      } else if (state != PlayerState.playing) {
        await _backgroundPlayer.play(
          AssetSource('audio/chill-background-music-438652.mp3'),
        );
      }
    } catch (e) {
      print('Error playing background music: $e');
      // Si le fichier n'existe pas, continue sans erreur
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _backgroundPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    await _backgroundPlayer.resume();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _backgroundPlayer.setVolume(_volume);
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    if (_isMusicEnabled) {
      await playBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }
  }

  Future<void> playCardSound() async {
    if (!_areEffectsEnabled) return;
    try {
      await _effectsPlayer.play(AssetSource('audio/card_play.mp3'));
    } catch (e) {
      print('Error playing card sound: $e');
    }
  }

  Future<void> playWinSound() async {
    if (!_areEffectsEnabled) return;
    try {
      await _effectsPlayer.play(AssetSource('audio/win.mp3'));
    } catch (e) {
      print('Error playing win sound: $e');
    }
  }

  Future<void> playLoseSound() async {
    if (!_areEffectsEnabled) return;
    try {
      await _effectsPlayer.play(AssetSource('audio/lose.mp3'));
    } catch (e) {
      print('Error playing lose sound: $e');
    }
  }

  void toggleEffects() {
    _areEffectsEnabled = !_areEffectsEnabled;
  }

  Future<void> dispose() async {
    await _backgroundPlayer.dispose();
    await _effectsPlayer.dispose();
  }
}
