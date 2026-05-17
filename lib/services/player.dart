import 'package:just_audio/just_audio.dart';
import '../models/station.dart';

class RadioPlayer {
  AudioPlayer _audioPlayer = AudioPlayer();

  Station? currentStation;

  Future<void> play(Station station) async {
    currentStation = station;
    final old = _audioPlayer;
    _audioPlayer = AudioPlayer();
    try { await old.dispose(); } catch (_) {}
    await _audioPlayer.setUrl(station.stream);
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    final old = _audioPlayer;
    _audioPlayer = AudioPlayer();
    try { await old.dispose(); } catch (_) {}
  }

  bool get isPlaying => _audioPlayer.playing;

  void dispose() {
    _audioPlayer.dispose();
  }
}