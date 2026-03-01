import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await LocalStorageService.loadSettings();
    setState(() {
      _settings = s ?? {
        'firstDayOfWeek': DateTime.monday, // 1
        'dateFormat': 'dd/MM/yyyy',
        'currency': '€',
        'notifications': false,
        'defaultReminderDays': 1,
        'defaultHome': 'home',
      };
    });
  }

  Future<void> _save() async {
    await LocalStorageService.saveSettings(_settings);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final first = _settings['firstDayOfWeek'] ?? DateTime.monday;
    final dateFormat = _settings['dateFormat'] ?? 'dd/MM/yyyy';
    final currency = _settings['currency'] ?? '€';

    return Scaffold(
      appBar: AppBar(title: Text(loc.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: Text(loc.t('first_day_of_week')),
            subtitle: Text(first == DateTime.monday ? loc.t('monday') : loc.t('sunday')),
            trailing: Switch(
              value: first == DateTime.monday,
              onChanged: (v) {
                setState(() {
                  _settings['firstDayOfWeek'] = v ? DateTime.monday : DateTime.sunday;
                });
                _save();
              },
            ),
          ),

          ListTile(
            title: Text(loc.t('date_format')),
            subtitle: Text(dateFormat),
            onTap: () async {
              final chosen = await showDialog<String>(
                context: context,
                builder: (c) => SimpleDialog(
                  title: Text(loc.t('date_format')),
                  children: [
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'dd/MM/yyyy'), child: const Text('dd/MM/yyyy')),
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'MM/dd/yyyy'), child: const Text('MM/dd/yyyy')),
                  ],
                ),
              );
              if (chosen != null) {
                setState(() => _settings['dateFormat'] = chosen);
                _save();
              }
            },
          ),

          ListTile(
            title: Text(loc.t('currency')),
            subtitle: Text(currency),
            onTap: () async {
              final ctrl = TextEditingController(text: currency);
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(loc.t('currency')),
                  content: TextField(controller: ctrl, decoration: InputDecoration(labelText: loc.t('symbol_label'))),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(loc.t('cancel'))),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: Text(loc.t('save'))),
                  ],
                ),
              );
              if (ok == true) {
                setState(() => _settings['currency'] = ctrl.text.trim());
                _save();
              }
            },
          ),

          ListTile(
            title: Text(loc.t('theme')),
            subtitle: Text((_settings['themeMode'] ?? 'system').toString()),
            onTap: () async {
              final chosen = await showDialog<String>(
                context: context,
                builder: (c) => SimpleDialog(
                  title: Text(loc.t('theme')),
                  children: [
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'system'), child: Text(loc.t('system'))),
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'light'), child: Text(loc.t('light'))),
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'dark'), child: Text(loc.t('dark'))),
                  ],
                ),
              );
              if (chosen != null) {
                setState(() => _settings['themeMode'] = chosen);
                _save();
              }
            },
          ),

          ListTile(
            title: Text(loc.t('language')),
            subtitle: Text((_settings['language'] ?? 'system').toString()),
            onTap: () async {
              final chosen = await showDialog<String>(
                context: context,
                builder: (c) => SimpleDialog(
                  title: Text(loc.t('language')),
                  children: [
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'system'), child: Text(loc.t('system'))),
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'it'), child: const Text('Italiano')),
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'en'), child: const Text('English')),
                  ],
                ),
              );
              if (chosen != null) {
                setState(() => _settings['language'] = chosen);
                _save();
              }
            },
          ),

          SwitchListTile(
            title: Text('Notifiche (promemoria)'),
            value: _settings['notifications'] ?? false,
            onChanged: (v) {
              setState(() => _settings['notifications'] = v);
              _save();
            },
          ),

          ListTile(
            title: const Text('Promemoria predefinito (giorni prima)'),
            subtitle: Text('${_settings['defaultReminderDays'] ?? 1} giorni'),
            onTap: () async {
              final ctrl = TextEditingController(text: (_settings['defaultReminderDays'] ?? 1).toString());
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Giorni prima'),
                  content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giorni')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salva')),
                  ],
                ),
              );
              if (ok == true) {
                final v = int.tryParse(ctrl.text) ?? 1;
                setState(() => _settings['defaultReminderDays'] = v);
                _save();
              }
            },
          ),

          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text('Backup (export)'),
            onTap: () async {
              // quick export: copy sections + settings to clipboard? For now just show a message
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export non implementato (prossimamente)')));
            },
          ),

          const SizedBox(height: 40),
          Center(child: Text(loc.t('settings'))),
        ],
      ),
    );
  }
}
