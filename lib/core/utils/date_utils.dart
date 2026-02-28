class DateUtilsHelper {
  static int daysRemaining(DateTime targetDate) {
    final now = DateTime.now();

    return targetDate.difference(now).inDays;
  }
}