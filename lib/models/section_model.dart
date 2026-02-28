import 'note_model.dart';

class SectionModel {
  final String id;
  final String name;
  final String icon;
  final List<NoteModel> notes;

  SectionModel({
    required this.id,
    required this.name,
    required this.icon,
    this.notes = const [],
  });
}