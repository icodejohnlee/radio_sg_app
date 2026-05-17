import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/station.dart';
import '../services/player.dart';
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
  final RadioPlayer player = RadioPlayer();

  List<Station> stations = [];
  List<String> favorites = [];

  Station? current;
  bool isPlaying = false;
  bool isOffline = false;

  bool showMenu = false;

  // 🔥 NEW MENU WIDTH
  final double menuWidth = 320;

  @override
  void initState() {
    super.initState();
    load();
    checkNetwork();
  }

  void checkNetwork() async {
    final results = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = results.every((r) => r == ConnectivityResult.none);
    });

    Connectivity().onConnectivityChanged.listen((results) {
      setState(() {
        isOffline = results.every((r) => r == ConnectivityResult.none);
      });
    });
  }

  void load() async {
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
        player.play(current!);
        isPlaying = true;
      }
    }

    setState(() {});
  }

  List<Station> get favStations =>
      stations.where((s) => favorites.contains(s.name)).toList();

  Future<void> togglePlay() async {
    if (isOffline || current == null) return;
    if (isPlaying) {
      setState(() => isPlaying = false);
      await player.stop();
    } else {
      setState(() => isPlaying = true);
      await player.play(current!);
      FavoritesService.saveLast(current!.name);
    }
  }

  void refreshFavorites() async {
    favorites = await FavoritesService.getFavorites();

    if (favorites.isNotEmpty && current == null) {
      current = stations.firstWhere(
        (s) => favorites.contains(s.name),
      );
    }

    if (favorites.isEmpty) {
      showMenu = true;
    }

    setState(() {});
  }

  String img(String path) => 'assets/$path';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BubbleBg(),

          // MAIN PAGE
          SafeArea(
            child: Column(
              children: [
                // 🔥 UPDATED TOP BAR (LEFT ALIGN)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.white),
                        onPressed: () {
                          setState(() {
                            showMenu = true;
                          });
                        },
                      ),
                      const SizedBox(width: 8),

                      const Text(
                        "Radio SG",
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
                      Icon(Icons.signal_wifi_off,
                          color: Colors.red, size: 60),
                      SizedBox(height: 10),
                      Text(
                        "No Signal / Offline",
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
                        onTap: togglePlay,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isPlaying ? Colors.red : Colors.green,
                          ),
                          child: Icon(
                            isPlaying
                                ? Icons.stop
                                : Icons.play_arrow,
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
                        final selected =
                            current?.name == s.name;

                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              current = s;
                              isPlaying = true;
                            });
                            if (!isOffline) {
                              await player.play(s);
                              FavoritesService.saveLast(s.name);
                            }
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration:
                                      BoxDecoration(
                                    shape:
                                        BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? Colors.green
                                          : Colors.white24,
                                      width: 3,
                                    ),
                                    image:
                                        DecorationImage(
                                      image: AssetImage(
                                          img(s.image)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
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

          // OUTSIDE TAP AREA
          if (showMenu)
            Positioned.fill(
              child: Row(
                children: [
                  SizedBox(width: menuWidth),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (favorites.isNotEmpty) {
                          setState(() {
                            showMenu = false;
                          });
                        }
                      },
                      child: Container(color: Colors.black26),
                    ),
                  ),
                ],
              ),
            ),

          // 🔥 BIGGER MENU PANEL
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
                      "Select Favourite Stations",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'VarelaRound',
                      ),
                    ),
                    const Divider(color: Colors.white24),

                    Expanded(
                      child: StationListPage(
                        onChanged: refreshFavorites,
                      ),
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