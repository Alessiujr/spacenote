import 'event_model.dart';

class SectionModel {
  final String id;
  final String name;
  final String icon;
  final List<EventModel> events;

  SectionModel({
    required this.id,
    required this.name,
    required this.icon,
    this.events = const [],
  });
}