import 'dart:convert';

class MonthlyRule {
  final String mode; // 'day', 'first_business_day', 'last_business_day', 'nth_weekday'
  final int? dayOfMonth;
  final int? nth; // 1..5 or -1 for last
  final int? weekday; // 1..7 (DateTime weekday)

  MonthlyRule({
    required this.mode,
    this.dayOfMonth,
    this.nth,
    this.weekday,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'dayOfMonth': dayOfMonth,
      'nth': nth,
      'weekday': weekday,
    };
  }

  factory MonthlyRule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MonthlyRule(mode: 'day', dayOfMonth: 1);
    return MonthlyRule(
      mode: json['mode'] ?? 'day',
      dayOfMonth: json['dayOfMonth'],
      nth: json['nth'],
      weekday: json['weekday'],
    );
  }
}

class RecurrenceRule {
  final String frequency; // 'none','daily','weekly','monthly','yearly'
  final int interval; // e.g., every N units
  final List<int>? weekdays; // for weekly rules (1..7)
  final MonthlyRule? monthlyRule;

  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.weekdays,
    this.monthlyRule,
  });

  factory RecurrenceRule.none() => RecurrenceRule(frequency: 'none');

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'interval': interval,
      'weekdays': weekdays,
      'monthlyRule': monthlyRule?.toJson(),
    };
  }

  factory RecurrenceRule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecurrenceRule.none();
    return RecurrenceRule(
      frequency: json['frequency'] ?? 'none',
      interval: json['interval'] ?? 1,
      weekdays: (json['weekdays'] as List?)?.map((e) => e as int).toList(),
      monthlyRule: MonthlyRule.fromJson(json['monthlyRule'] as Map<String, dynamic>? ),
    );
  }

  String toReadableString() {
    if (frequency == 'none') return 'No recurrence';
    if (frequency == 'daily') return 'Every $interval day(s)';
    if (frequency == 'weekly') {
      final days = (weekdays ?? []).map((d) => _weekdayName(d)).join(', ');
      return 'Every $interval week(s) on $days';
    }
    if (frequency == 'monthly') {
      final mr = monthlyRule;
      if (mr == null) return 'Every $interval month(s)';
      if (mr.mode == 'day') return 'Every month on day ${mr.dayOfMonth}';
      if (mr.mode == 'first_business_day') return 'Every month on first business day';
      if (mr.mode == 'last_business_day') return 'Every month on last business day';
      if (mr.mode == 'nth_weekday') {
        final nth = mr.nth == -1 ? 'last' : '${mr.nth}º';
        return 'Every month on $nth ${_weekdayName(mr.weekday ?? 1)}';
      }
      return 'Every $interval month(s)';
    }
    if (frequency == 'yearly') return 'Every year';
    return 'Custom recurrence';
  }

  String _weekdayName(int d) {
    switch (d) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return 'Day$d';
    }
  }
}

class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final RecurrenceRule recurrence;
  final double? cost;
  final String? notes;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    RecurrenceRule? recurrence,
    this.cost,
    this.notes,
  }) : recurrence = recurrence ?? RecurrenceRule.none();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'recurrence': recurrence.toJson(),
      'cost': cost,
      'notes': notes,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      recurrence: RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>? ),
      cost: json['cost'] == null
          ? null
          : (json['cost'] is num
              ? (json['cost'] as num).toDouble()
              : double.tryParse(json['cost'].toString())),
      notes: json['notes'] as String?,
    );
  }
}