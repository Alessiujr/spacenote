import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String sectionsKey = "spacenote_sections";
  static const String settingsKey = "spacenote_settings";

  // Accept dynamic maps so we can store nested event objects (maps)
  static Future<void> saveSections(List<Map<String, dynamic>> sections) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(sectionsKey, jsonEncode(sections));
  }

  static Future<List<Map<String, dynamic>>> loadSections() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(sectionsKey);

    if (data == null) return [];

    List<dynamic> decoded = jsonDecode(data);

    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(settingsKey, jsonEncode(settings));
    // notify listeners
    try {
      settingsNotifier.value = Map<String, dynamic>.from(settings);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(settingsKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        settingsNotifier.value = Map<String, dynamic>.from(decoded);
      }
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  // Notifier to allow app to react to settings changes (e.g., theme)
  static final ValueNotifier<Map<String, dynamic>?> settingsNotifier = ValueNotifier(null);
}