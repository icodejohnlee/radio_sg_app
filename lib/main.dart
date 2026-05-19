import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'services/radio_handler.dart';
import 'ui/player_page.dart';

RadioHandler? _audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    _audioHandler = await AudioService.init(
      builder: () => RadioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.radiosg.channel',
        androidNotificationChannelName: 'Radio SG',
      ),
    );
  }
  runApp(SGRadioApp(audioHandler: _audioHandler));
}

class SGRadioApp extends StatelessWidget {
  final RadioHandler? audioHandler;
  const SGRadioApp({super.key, this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SG Radio',
      theme: ThemeData.dark(),
      home: PlayerPage(audioHandler: audioHandler),
    );
  }
}
