import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/station.dart';

class RadioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  Station? currentStation;

  RadioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<void> playStation(Station station) async {
    currentStation = station;
    final artUri = await _assetToFileUri('assets/${station.image}');
    mediaItem.add(MediaItem(
      id: station.stream,
      title: station.name,
      artist: station.genre,
      artUri: artUri,
    ));
    await _player.stop();
    await _player.setUrl(station.stream);
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  // Stops audio when user swipes the app away on Android
  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  // Copies a Flutter asset to a temp file and returns its file:// URI
  Future<Uri?> _assetToFileUri(String assetPath) async {
    try {
      final bytes = await rootBundle.load(assetPath);
      final dir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      return file.uri;
    } catch (_) {
      return null;
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
    );
  }
}
