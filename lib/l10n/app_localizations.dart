import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Spacenote',
      'settings': 'Settings',
      'first_day_of_week': 'First day of week',
      'monday': 'Monday',
      'sunday': 'Sunday',
      'date_format': 'Date format',
      'currency': 'Currency',
      'symbol_label': 'Symbol (e.g. € or \$)',
      'theme': 'Theme',
      'language': 'Language',
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',
      'save': 'Save',
      'cancel': 'Cancel',
      'add_space': 'Add Space',
      'space_name': 'Space name',
      'delete_space_title': 'Delete Space',
      'delete_space_confirm': 'Are you sure you want to delete this space?',
      'delete': 'Delete',
      'no_upcoming_deadlines': 'No upcoming deadlines',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'date': 'Date',
      'edit_event': 'Edit Event',
      'delete_event': 'Delete this event?',
    },
    'it': {
      'app_title': 'Spacenote',
      'settings': 'Impostazioni',
      'first_day_of_week': 'Primo giorno della settimana',
      'monday': 'Lunedì',
      'sunday': 'Domenica',
      'date_format': 'Formato data',
      'currency': 'Valuta predefinita',
      'symbol_label': 'Simbolo (es. € or \$)',
      'theme': 'Tema',
      'language': 'Lingua',
      'system': 'Sistema',
      'light': 'Light',
      'dark': 'Dark',
      'save': 'Salva',
      'cancel': 'Annulla',
      'add_space': 'Aggiungi spazio',
      'space_name': 'Nome spazio',
      'delete_space_title': 'Elimina spazio',
      'delete_space_confirm': 'Sei sicuro di voler eliminare questo spazio?',
      'delete': 'Elimina',
      'no_upcoming_deadlines': 'Nessuna scadenza',
      'close': 'Chiudi',
      'yes': 'Si',
      'no': 'No',
      'date': 'Data',
      'edit_event': 'Modifica evento',
      'delete_event': 'Eliminare questo evento?',
    }
  };

  String t(String key) {
    final code = locale.languageCode;
    if (_localizedValues.containsKey(code) && _localizedValues[code]!.containsKey(key)) {
      return _localizedValues[code]![key]!;
    }
    // fallback to English
    return _localizedValues['en']![key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'it'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
