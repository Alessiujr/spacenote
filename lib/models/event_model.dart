import 'dart:convert';

class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String recurrence;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    this.recurrence = "none",
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "date": date.toIso8601String(),
      "recurrence": recurrence,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json["id"],
      title: json["title"],
      date: DateTime.parse(json["date"]),
      recurrence: json["recurrence"] ?? "none",
    );
  }
}