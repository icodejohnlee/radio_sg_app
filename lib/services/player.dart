import 'package:just_audio/just_audio.dart';
import '../models/station.dart';

class RadioPlayer {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(Station station) async {
    await _player.stop();
    await _player.setUrl(station.stream);
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
