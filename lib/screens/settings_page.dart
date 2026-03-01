import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

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
    final first = _settings['firstDayOfWeek'] ?? DateTime.monday;
    final dateFormat = _settings['dateFormat'] ?? 'dd/MM/yyyy';
    final currency = _settings['currency'] ?? '€';

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: const Text('Primo giorno della settimana'),
            subtitle: Text(first == DateTime.monday ? 'Lunedì' : 'Domenica'),
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
            title: const Text('Formato data'),
            subtitle: Text(dateFormat),
            onTap: () async {
              final chosen = await showDialog<String>(
                context: context,
                builder: (c) => SimpleDialog(
                  title: const Text('Formato data'),
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
            title: const Text('Valuta predefinita'),
            subtitle: Text(currency),
            onTap: () async {
              final ctrl = TextEditingController(text: currency);
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Valuta'),
                  content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Simbolo (es. € or \$)')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salva')),
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
            title: const Text('Tema'),
            subtitle: Text((_settings['themeMode'] ?? 'system').toString()),
            onTap: () async {
              final chosen = await showDialog<String>(
                context: context,
                builder: (c) => SimpleDialog(
                  title: const Text('Tema'),
                  children: [
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'system'), child: const Text('System')),
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'light'), child: const Text('Light')),
                    SimpleDialogOption(onPressed: () => Navigator.pop(c, 'dark'), child: const Text('Dark')),
                  ],
                ),
              );
              if (chosen != null) {
                setState(() => _settings['themeMode'] = chosen);
                _save();
              }
            },
          ),

          SwitchListTile(
            title: const Text('Notifiche (promemoria)'),
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
            title: const Text('Backup (export)'),
            onTap: () async {
              // quick export: copy sections + settings to clipboard? For now just show a message
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export non implementato (prossimamente)')));
            },
          ),

          const SizedBox(height: 40),
          Center(child: Text('Impostazioni applicate localmente')),
        ],
      ),
    );
  }
}
