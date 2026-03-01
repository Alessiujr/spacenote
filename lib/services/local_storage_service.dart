import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String sectionsKey = "spacenote_sections";

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
}