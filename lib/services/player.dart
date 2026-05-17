import 'package:just_audio/just_audio.dart';
import '../models/station.dart';

class RadioPlayer {
  AudioPlayer _audioPlayer = AudioPlayer();

  Station? currentStation;

  Future<void> play(Station station) async {
    currentStation = station;
    final old = _audioPlayer;
    _audioPlayer = AudioPlayer();
    // Stop old stream immediately, then dispose in background
    try { await old.stop(); } catch (_) {}
    old.dispose().catchError((_) {});
    await _audioPlayer.setUrl(station.stream);
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    final old = _audioPlayer;
    _audioPlayer = AudioPlayer();
    // Stop immediately, dispose in background
    try { await old.stop(); } catch (_) {}
    old.dispose().catchError((_) {});
  }

  bool get isPlaying => _audioPlayer.playing;

  void dispose() {
    _audioPlayer.dispose();
  }
}