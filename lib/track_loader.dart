import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<String>> loadTracks() async {
  try {
    // Load the JSON file
    final String response = await rootBundle.loadString('assets/tracks.json');
    final List<dynamic> data = json.decode(response);
    return data.map((track) => track['name'] as String).toList();
  } catch (e) {
    print('Error loading tracks: $e');
    return [];
  }
} 