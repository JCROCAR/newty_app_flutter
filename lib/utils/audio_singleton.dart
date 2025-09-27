import 'package:audioplayers/audioplayers.dart';

class BackgroundMusic {
  static final BackgroundMusic _instance = BackgroundMusic._internal();
  factory BackgroundMusic() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _enabled = true; // <-- nuevo: guarda si el sonido está activado o no

  BackgroundMusic._internal();

  bool get isPlaying => _isPlaying;
  bool get isEnabled => _enabled;

  void enable() {
    _enabled = true;
    play();
  }

  void disable() {
    _enabled = false;
    stop();
  }

  Future<void> play() async {
    if (_enabled && !_isPlaying) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('background-audio.mp3'));
      _isPlaying = true;
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }
}
