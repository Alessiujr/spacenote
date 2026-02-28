import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const SpaceNoteApp());
}

class SpaceNoteApp extends StatelessWidget {
  const SpaceNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}