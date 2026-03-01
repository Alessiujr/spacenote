class AppSettings {
  final String theme; // 'system','light','dark'
  final int firstDayOfWeek; // 1=Mon .. 7=Sun
  final bool notificationsEnabled;
  final int reminderDays; // default advance in days
  final String currency; // symbol or code
  final String dateFormat; // e.g. 'dd/MM/yyyy'

  AppSettings({
    this.theme = 'system',
    this.firstDayOfWeek = 1,
    this.notificationsEnabled = false,
    this.reminderDays = 1,
    this.currency = '€',
    this.dateFormat = 'dd/MM/yyyy',
  });

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'firstDayOfWeek': firstDayOfWeek,
      'notificationsEnabled': notificationsEnabled,
      'reminderDays': reminderDays,
      'currency': currency,
      'dateFormat': dateFormat,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AppSettings();
    return AppSettings(
      theme: json['theme'] ?? 'system',
      firstDayOfWeek: (json['firstDayOfWeek'] is int) ? json['firstDayOfWeek'] as int : 1,
      notificationsEnabled: json['notificationsEnabled'] == true,
      reminderDays: (json['reminderDays'] is int) ? json['reminderDays'] as int : 1,
      currency: json['currency'] ?? '€',
      dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
    );
  }
}
