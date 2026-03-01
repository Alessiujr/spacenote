import '../../models/event_model.dart';

class DateUtilsHelper {
  static int daysRemaining(DateTime targetDate) {
    final now = DateTime.now();

    return targetDate.difference(now).inDays;
  }

  static int _daysInMonth(int year, int month) {
    final nextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  static DateTime _nthWeekdayOfMonth(int year, int month, int weekday, int nth) {
    if (nth == -1) {
      // last weekday
      final days = _daysInMonth(year, month);
      for (int d = days; d >= 1; d--) {
        final dt = DateTime(year, month, d);
        if (dt.weekday == weekday) return dt;
      }
    } else {
      int count = 0;
      for (int d = 1; d <= _daysInMonth(year, month); d++) {
        final dt = DateTime(year, month, d);
        if (dt.weekday == weekday) {
          count++;
          if (count == nth) return dt;
        }
      }
    }

    // fallback: first day
    return DateTime(year, month, 1);
  }

  static DateTime _firstBusinessDay(int year, int month) {
    for (int d = 1; d <= _daysInMonth(year, month); d++) {
      final dt = DateTime(year, month, d);
      if (dt.weekday >= DateTime.monday && dt.weekday <= DateTime.friday) return dt;
    }
    return DateTime(year, month, 1);
  }

  static DateTime _lastBusinessDay(int year, int month) {
    for (int d = _daysInMonth(year, month); d >= 1; d--) {
      final dt = DateTime(year, month, d);
      if (dt.weekday >= DateTime.monday && dt.weekday <= DateTime.friday) return dt;
    }
    return DateTime(year, month, _daysInMonth(year, month));
  }

  static DateTime nextOccurrence(DateTime baseDate, RecurrenceRule rule) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (rule.frequency == 'none') return baseDate;

    if (rule.frequency == 'daily') {
      DateTime candidate = DateTime(baseDate.year, baseDate.month, baseDate.day);
      if (!candidate.isAfter(now)) {
        final daysToAdd = ((now.difference(candidate).inDays) ~/ rule.interval + 1) * rule.interval;
        candidate = candidate.add(Duration(days: daysToAdd));
      }
      return candidate;
    }

    if (rule.frequency == 'weekly') {
      final weekdays = rule.weekdays ?? [baseDate.weekday];
      // search next occurrence within next 52 weeks
      for (int week = 0; week < 52; week++) {
        for (final wd in weekdays) {
          final offset = ((wd - today.weekday) % 7 + 7) % 7; // ensure positive
          final candidate = DateTime(today.year, today.month, today.day).add(Duration(days: (week * 7) + offset));
          if (!candidate.isBefore(today)) return candidate;
        }
      }
      return baseDate;
    }

    if (rule.frequency == 'monthly') {
      final mr = rule.monthlyRule;
      int year = now.year;
      int month = now.month;

      for (int i = 0; i < 120; i++) {
        final y = year + ((month + i - 1) ~/ 12);
        final m = ((month + i - 1) % 12) + 1;
        DateTime candidate;

        if (mr == null || mr.mode == 'day') {
          final day = mr?.dayOfMonth ?? baseDate.day;
          final d = day <= _daysInMonth(y, m) ? day : _daysInMonth(y, m);
          candidate = DateTime(y, m, d);
        } else if (mr.mode == 'first_business_day') {
          candidate = _firstBusinessDay(y, m);
        } else if (mr.mode == 'last_business_day') {
          candidate = _lastBusinessDay(y, m);
        } else if (mr.mode == 'nth_weekday') {
          candidate = _nthWeekdayOfMonth(y, m, mr.weekday ?? baseDate.weekday, mr.nth ?? 1);
        } else {
          final d = baseDate.day <= _daysInMonth(y, m) ? baseDate.day : _daysInMonth(y, m);
          candidate = DateTime(y, m, d);
        }

        if (!candidate.isBefore(today)) return candidate;
      }

      return baseDate;
    }

    if (rule.frequency == 'yearly') {
      int year = now.year;
      DateTime candidate = DateTime(year, baseDate.month, baseDate.day);
      if (candidate.isBefore(today)) candidate = DateTime(year + 1, baseDate.month, baseDate.day);
      return candidate;
    }

    return baseDate;
  }
}