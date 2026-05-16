import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/station_loader.dart';
import '../services/favorites_service.dart';

class StationListPage extends StatefulWidget {
  final VoidCallback onChanged;

  const StationListPage({super.key, required this.onChanged});

  @override
  State<StationListPage> createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  List<Station> stations = [];
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    stations = await StationLoader.load();
    favorites = await FavoritesService.getFavorites();
    setState(() {});
  }

  bool isFav(String name) => favorites.contains(name);

  void toggle(String name) async {
    await FavoritesService.toggleFavorite(name);
    favorites = await FavoritesService.getFavorites();
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: ListView(
              children: [
                const SizedBox(height: 0),
                const SizedBox(height: 20),
                ...stations.map((s) {
                  return ListTile(
                    title: Text(s.name,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(s.genre,
                        style: const TextStyle(color: Colors.white60)),
                    trailing: IconButton(
                      icon: Icon(
                        isFav(s.name)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => toggle(s.name),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}