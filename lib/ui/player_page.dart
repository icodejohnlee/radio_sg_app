import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/station.dart';
import '../services/player.dart';
import '../services/radio_handler.dart';
import '../services/station_loader.dart';
import '../services/favorites_service.dart';
import 'bubble_bg.dart';
import 'station_list_page.dart';
import 'audio_visualizer.dart';

class PlayerPage extends StatefulWidget {
  final RadioHandler? audioHandler;
  const PlayerPage({super.key, this.audioHandler});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  // Android only — iOS uses widget.audioHandler via audio_service
  late final RadioPlayer? _player = Platform.isAndroid ? RadioPlayer() : null;

  List<Station> stations = [];
  List<String> favorites = [];

  Station? current;
  bool isPlaying = false;
  bool isOffline = false;
  bool showMenu = false;

  final double menuWidth = 320;

  @override
  void initState() {
    super.initState();
    _load();
    _checkNetwork();
  }

  Future<void> _play(Station s) async {
    if (Platform.isIOS) {
      await widget.audioHandler!.playStation(s);
    } else {
      await _player!.play(s);
    }
  }

  Future<void> _stop() async {
    if (Platform.isIOS) {
      await widget.audioHandler!.stop();
    } else {
      await _player!.stop();
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  void _checkNetwork() async {
    final results = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = results.every((r) => r == ConnectivityResult.none);
    });
    Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) {
        setState(() {
          isOffline = results.every((r) => r == ConnectivityResult.none);
        });
      }
    });
  }

  void _load() async {
    stations = await StationLoader.load();
    favorites = await FavoritesService.getFavorites();

    if (favorites.isEmpty) {
      showMenu = true;
    } else {
      final last = await FavoritesService.getLast();
      if (last != null) {
        current = stations.firstWhere(
          (s) => s.name == last,
          orElse: () => stations.first,
        );
        setState(() => isPlaying = true);
        _play(current!);
      }
    }

    setState(() {});
  }

  List<Station> get favStations =>
      stations.where((s) => favorites.contains(s.name)).toList();

  Future<void> _togglePlay() async {
    if (isOffline || current == null) return;
    if (isPlaying) {
      setState(() => isPlaying = false);
      await _stop();
    } else {
      setState(() => isPlaying = true);
      await _play(current!);
      FavoritesService.saveLast(current!.name);
    }
  }

  Future<void> _switchStation(Station s) async {
    if (isOffline) return;
    setState(() {
      current = s;
      isPlaying = true;
    });
    await _play(s);
    FavoritesService.saveLast(s.name);
  }

  void _refreshFavorites() async {
    favorites = await FavoritesService.getFavorites();
    if (favorites.isNotEmpty && current == null) {
      current = stations.firstWhere((s) => favorites.contains(s.name));
    }
    if (favorites.isEmpty) showMenu = true;
    setState(() {});
  }

  String img(String path) => 'assets/$path';

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

                if (isOffline)
                  const Column(
                    children: [
                      Icon(Icons.signal_wifi_off, color: Colors.red, size: 60),
                      SizedBox(height: 10),
                      Text(
                        'No Signal / Offline',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontFamily: 'VarelaRound',
                        ),
                      ),
                    ],
                  )
                else if (current != null)
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
                          onTap: () => _switchStation(s),
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

          // Outside tap to close menu
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

          // Menu panel
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
