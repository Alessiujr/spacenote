import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/section_model.dart';

class SectionNotifier extends StateNotifier<List<SectionModel>> {
  SectionNotifier() : super([]);

  void addSection(SectionModel section) {
    state = [...state, section];
  }
}

final sectionProvider =
    StateNotifierProvider<SectionNotifier, List<SectionModel>>(
  (ref) => SectionNotifier(),
);