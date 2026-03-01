import '../models/section_model.dart';

class SectionNotifier {
  List<SectionModel> state = [];

  void addSection(SectionModel section) {
    state = [...state, section];
  }
}