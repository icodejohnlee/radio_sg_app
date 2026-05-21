import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/station.dart';
import '../services/station_loader.dart';
import '../services/favorites_service.dart';
import 'bubble_bg.dart';
import 'station_list_page.dart';
import 'audio_visualizer.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final AudioPlayer _player = AudioPlayer();

  List<Station> stations = [];
  List<String> favorites = [];
  Station? current;
  bool isPlaying = false;
  bool showMenu = false;

  final double menuWidth = 320;

  @override
  void initState() {
    super.initState();
    _setupAndLoad();
  }

  Future<void> _setupAndLoad() async {
    await _setupAudio();
    await _load();
  }

  Future<void> _setupAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> _load() async {
    final results = await Future.wait([
      StationLoader.load(),
      FavoritesService.getFavorites(),
      FavoritesService.getLast(),
    ]);

    stations = results[0] as List<Station>;
    favorites = results[1] as List<String>;
    final last = results[2] as String?;

    if (favorites.isEmpty) {
      showMenu = true;
      setState(() {});
    } else if (last != null) {
      final station = stations.firstWhere(
        (s) => s.name == last,
        orElse: () => stations.first,
      );
      await _play(station);
    } else {
      setState(() {});
    }
  }

  Future<void> _play(Station s) async {
    setState(() {
      current = s;
      isPlaying = true;
    });
    FavoritesService.saveLast(s.name);
    try {
      await _player.stop();
      await _player.setUrl(s.stream);
      await _player.play();
    } catch (_) {
      setState(() => isPlaying = false);
    }
  }

  Future<void> _stop() async {
    setState(() => isPlaying = false);
    await _player.stop();
  }

  Future<void> _togglePlay() async {
    if (current == null) return;
    if (isPlaying) {
      await _stop();
    } else {
      await _play(current!);
    }
  }

  void _refreshFavorites() async {
    favorites = await FavoritesService.getFavorites();
    if (favorites.isNotEmpty && current == null) {
      current = stations.firstWhere((s) => favorites.contains(s.name));
    }
    if (favorites.isEmpty) showMenu = true;
    setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String img(String path) => 'assets/$path';

  List<Station> get favStations =>
      stations.where((s) => favorites.contains(s.name)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BubbleBg(),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => setState(() => showMenu = true),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Radio SG',
                        style: TextStyle(
                          fontFamily: 'VarelaRound',
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                if (current != null)
                  Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(img(current!.image)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        current!.genre,
                        style: const TextStyle(
                          fontFamily: 'VarelaRound',
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AudioVisualizer(isPlaying: isPlaying),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPlaying ? Colors.red : Colors.green,
                          ),
                          child: Icon(
                            isPlaying ? Icons.stop : Icons.play_arrow,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),
                      ),
                    ],
                  ),

                const Spacer(),

                if (favStations.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: favStations.map((s) {
                        final selected = current?.name == s.name;
                        return GestureDetector(
                          onTap: () => _play(s),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? Colors.green : Colors.white24,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(img(s.image)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Dim area to close menu
          if (showMenu)
            Positioned.fill(
              child: Row(
                children: [
                  SizedBox(width: menuWidth),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (favorites.isNotEmpty) {
                          setState(() => showMenu = false);
                        }
                      },
                      child: Container(color: Colors.black26),
                    ),
                  ),
                ],
              ),
            ),

          // Slide-in menu
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: showMenu ? 0 : -menuWidth,
            top: 0,
            bottom: 0,
            width: menuWidth,
            child: Material(
              color: Colors.black.withValues(alpha: 0.95),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Select Favourite Stations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'VarelaRound',
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    Expanded(
                      child: StationListPage(onChanged: _refreshFavorites),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
