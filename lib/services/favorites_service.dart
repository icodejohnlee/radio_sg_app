import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const favKey = "favorites";
  static const lastKey = "last_station";

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(favKey) ?? [];
  }

  static Future<void> toggleFavorite(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(favKey) ?? [];

    if (list.contains(name)) {
      list.remove(name);
    } else {
      list.add(name);
    }

    await prefs.setStringList(favKey, list);
  }

  static Future<void> saveLast(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastKey, name);
  }

  static Future<String?> getLast() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastKey);
  }
}