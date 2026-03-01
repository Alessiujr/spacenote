import 'event_model.dart';

class SectionModel {
  final String id;
  final String name;
  final String icon;
  final List<EventModel> events;
  final String? imagePath;

  SectionModel({
    required this.id,
    required this.name,
    required this.icon,
    this.events = const [],
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'events': events.map((e) => e.toJson()).toList(),
      'imagePath': imagePath,
    };
  }

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    final evs = json['events'];
    List<EventModel> parsed = [];
    if (evs is List) {
      parsed = evs.map((e) => EventModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    return SectionModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      icon: json['icon'] ?? '📌',
      events: parsed,
      imagePath: json['imagePath'],
    );
  }
}