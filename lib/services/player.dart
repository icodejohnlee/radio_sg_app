import 'package:just_audio/just_audio.dart';
import '../models/station.dart';

class RadioPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Station? currentStation;

  /// Play selected station
  Future<void> play(Station station) async {
    try {
      currentStation = station;

      // Stop previous stream first (important for switching)
      await _audioPlayer.stop();

      // Load new stream
      await _audioPlayer.setUrl(station.stream);

      // Play audio
      await _audioPlayer.play();
    } catch (e) {
      throw Exception("Failed to play station: $e");
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Stop playback completely
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Check if playing
  bool get isPlaying => _audioPlayer.playing;

  /// Dispose player (optional but good practice)
  void dispose() {
    _audioPlayer.dispose();
  }
}