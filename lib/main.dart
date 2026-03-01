import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.loadSettings(); // initialize notifier
  runApp(const SpaceNoteApp());
}

class SpaceNoteApp extends StatefulWidget {
  const SpaceNoteApp({super.key});

  @override
  State<SpaceNoteApp> createState() => _SpaceNoteAppState();
}

class _SpaceNoteAppState extends State<SpaceNoteApp> {
  @override
  void initState() {
    super.initState();
    LocalStorageService.settingsNotifier.addListener(() {
      setState(() {});
    });
  }

  ThemeMode _themeModeFromSettings() {
    final s = LocalStorageService.settingsNotifier.value;
    final mode = s == null ? 'system' : (s['themeMode'] ?? 'system');
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      themeMode: _themeModeFromSettings(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}