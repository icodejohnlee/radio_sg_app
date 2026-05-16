import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/station.dart';

class StationLoader {
  static Future<List<Station>> load() async {
    final data = await rootBundle.loadString('assets/stations.json');
    final List jsonResult = json.decode(data);

    return jsonResult.map((e) => Station.fromJson(e)).toList();
  }
}