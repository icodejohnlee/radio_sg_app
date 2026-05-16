import 'package:flutter/material.dart';
import 'ui/player_page.dart';

void main() {
  runApp(const SGRadioApp());
}

class SGRadioApp extends StatelessWidget {
  const SGRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SG Radio',
      theme: ThemeData.dark(),
      home: const PlayerPage(),
    );
  }
}