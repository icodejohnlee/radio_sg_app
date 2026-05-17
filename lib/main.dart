import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'services/radio_handler.dart';
import 'ui/player_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final handler = await AudioService.init(
    builder: () => RadioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.icodejohnlee.sg_radio_app.channel',
      androidNotificationChannelName: 'Radio SG',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(SGRadioApp(handler: handler));
}

class SGRadioApp extends StatelessWidget {
  final RadioHandler handler;
  const SGRadioApp({super.key, required this.handler});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SG Radio',
      theme: ThemeData.dark(),
      home: PlayerPage(handler: handler),
    );
  }
}
