import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<String>> loadTemplates() async {
  try {
    // Load the JSON file
    final String response = await rootBundle.loadString('assets/templates.json');
    final List<dynamic> data = json.decode(response);
    return data.map((template) => template['name'] as String).toList();
  } catch (e) {
    print('Error loading templates: $e');
    return [];
  }
} 