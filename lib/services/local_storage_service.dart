import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String sectionsKey = "spacenote_sections";

  static Future<void> saveSections(
      List<Map<String, String>> sections) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(sectionsKey, jsonEncode(sections));
  }

  static Future<List<Map<String, String>>> loadSections() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(sectionsKey);

    if (data == null) return [];

    List<dynamic> decoded = jsonDecode(data);

    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }
}