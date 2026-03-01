import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/utils/date_utils.dart';
import '../services/local_storage_service.dart';
import 'space_detail_page.dart';
import '../models/event_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> sections = [
    
  ];

  late int _displayMonth;
  late int _displayYear;

  String selectedSection = "Home";

  final List<String> availableIcons = [
    "🏠",
    "🚗",
    "🛵",
    "📂",
    "✈️",
    "💡",
    "📌",
    "🧾"
  ];

  @override
  void initState() {
    super.initState();
    _loadSections();
    final now = DateTime.now();
    _displayMonth = now.month;
    _displayYear = now.year;
  }

  /// Load storage
  void _loadSections() async {
    final data = await LocalStorageService.loadSections();

    if (data.isNotEmpty) {
      setState(() {
        // Normalize loaded sections: ensure events is a List
        sections = data.map((s) {
          final name = s['name'];
          final icon = s['icon'];
          final imagePath = s['imagePath'];
          var events = s['events'];

          if (events is String) {
            try {
              final decoded = jsonDecode(events);
              events = decoded is List ? decoded : [];
            } catch (_) {
              events = [];
            }
          }

          if (events == null) events = [];

          return {
            'name': name,
            'icon': icon,
            'events': events,
            'imagePath': imagePath,
          };
        }).toList();

        selectedSection = sections.isNotEmpty ? sections.first['name'] : '';
      });
    }
  }

  /// Save storage helper
  Future<void> _saveSections() async {
    // Build serializable sections: ensure events are converted to JSON maps
    final serializable = sections.map((section) {
      final events = section['events'];
      List<dynamic> eventsJson = [];

      if (events is List) {
        eventsJson = events.map((ev) {
          if (ev is EventModel) return ev.toJson();
          if (ev is Map) return Map<String, dynamic>.from(ev);
          return ev;
        }).toList();
      }

      return {
        'name': section['name'],
        'icon': section['icon'],
        'events': eventsJson,
        'imagePath': section['imagePath'],
      };
    }).toList();

    await LocalStorageService.saveSections(serializable);
  }

  /// Add space dialog
  void _showAddSectionDialog() {
    final nameController = TextEditingController();
    String selectedIcon = availableIcons.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Space"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Space name"),
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    children: availableIcons.map((icon) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedIcon = icon;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedIcon == icon
                                  ? Colors.deepPurple
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(icon,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    setState(() {
                      sections.add({
                        "name": nameController.text,
                        "icon": selectedIcon,
                        "events": [],
                      });

                      selectedSection = nameController.text;
                    });

                    await _saveSections();

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✨ Space Created"),
                      ),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Drawer UI
  Widget _buildDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...sections.map((section) {
            return ListTile(
                    selected: selectedSection == section["name"],
                    selectedTileColor: Colors.deepPurple.withOpacity(0.1),
                    leading: Text(section["icon"] ?? "📌"),
                    title: Text(section["name"]),

              onTap: () {
                Navigator.pop(context);

                setState(() {
                  selectedSection = section["name"];
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      final rawEvents = section['events'];
                      final eventsList = (rawEvents is List)
                          ? rawEvents
                              .map<EventModel>((e) =>
                                  EventModel.fromJson(Map<String, dynamic>.from(e)))
                              .toList()
                          : <EventModel>[];

                      return SpaceDetailPage(
                        spaceName: section['name'],
                        events: eventsList,
                        imagePath: section['imagePath'],
                        onImageChanged: (newPath) async {
                          setState(() {
                            final idx = sections.indexWhere((s) => s['name'] == section['name']);
                            if (idx != -1) sections[idx]['imagePath'] = newPath;
                          });
                          await _saveSections();
                        },
                        onEventsChanged: (updated) async {
                          // persist updated events back into sections and save
                          setState(() {
                            final idx = sections.indexWhere((s) => s['name'] == section['name']);
                            if (idx != -1) {
                              sections[idx]['events'] = updated.map((e) => e.toJson()).toList();
                            }
                          });

                          await _saveSections();
                        },
                      );
                    },
                  ),
                );
              },

              onLongPress: () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Space"),
                    content: const Text(
                        "Are you sure you want to delete this space?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            sections.removeWhere(
                                (e) => e["name"] == section["name"]);
                          });

                          await _saveSections();

                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),

          const Divider(),

          ListTile(
            leading: const Text("➕"),
            title: const Text("Add Space"),
            onTap: () {
              Navigator.pop(context);
              _showAddSectionDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Gather all events from sections, compute next occurrence and sort
    final List<Map<String, dynamic>> upcoming = [];

    for (final section in sections) {
      final sectionName = section['name'] ?? '';
      final sectionIcon = section['icon'] ?? '📌';
      final rawEvents = section['events'];

      if (rawEvents is List) {
        for (final e in rawEvents) {
          try {
            final ev = e is EventModel ? e : EventModel.fromJson(Map<String, dynamic>.from(e));
            final next = DateUtilsHelper.nextOccurrence(ev.date, ev.recurrence);
            upcoming.add({
              'space': sectionName,
              'icon': sectionIcon,
              'event': ev,
              'nextDate': next,
              'daysLeft': DateUtilsHelper.daysRemaining(next),
            });
          } catch (_) {
            // ignore malformed events
          }
        }
      }
    }

    upcoming.sort((a, b) => (a['nextDate'] as DateTime).compareTo(b['nextDate'] as DateTime));

    Widget calendar = _buildCalendar(upcoming);

    Widget list = upcoming.isEmpty
        ? const Center(child: Text("No upcoming deadlines"))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcoming.length,
            itemBuilder: (context, index) {
              final item = upcoming[index];
              final EventModel ev = item['event'];
              final DateTime next = item['nextDate'];
              final int daysLeft = item['daysLeft'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Text(item['icon'], style: const TextStyle(fontSize: 22)),
                  title: Text(ev.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item['space']} • Next: ${next.day}/${next.month}/${next.year}'),
                      const SizedBox(height: 4),
                      Text(ev.recurrence.toReadableString()),
                      const SizedBox(height: 6),
                      Text(daysLeft >= 0 ? '⏳ ${DateUtilsHelper.formatRemaining(next)}' : '⚠️ Scaduto', style: TextStyle(color: daysLeft < 0 ? Colors.red : Colors.green)),
                    ],
                  ),
                  trailing: ev.cost != null ? Text('€' + ev.cost!.toStringAsFixed(2)) : const Icon(Icons.chevron_right),
                  onTap: () {
                    // open space detail for this event's space
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          // build events list and find imagePath for the target space
                          final targetSection = sections.firstWhere((s) => s['name'] == item['space'], orElse: () => <String, dynamic>{});
                          final raw = (targetSection is Map && targetSection.isNotEmpty) ? targetSection['events'] : [];
                          final eventsList = (raw is List) ? raw.map<EventModel>((e) => e is EventModel ? e : EventModel.fromJson(Map<String, dynamic>.from(e))).toList() : <EventModel>[];
                          final imagePath = (targetSection is Map && targetSection.isNotEmpty) ? targetSection['imagePath'] : null;

                          return SpaceDetailPage(
                            spaceName: item['space'],
                            events: eventsList,
                            imagePath: imagePath,
                            onImageChanged: (newPath) async {
                              setState(() {
                                final idx = sections.indexWhere((s) => s['name'] == item['space']);
                                if (idx != -1) sections[idx]['imagePath'] = newPath;
                              });
                              await _saveSections();
                            },
                            onEventsChanged: (updated) async {
                              setState(() {
                                final idx = sections.indexWhere((s) => s['name'] == item['space']);
                                if (idx != -1) sections[idx]['events'] = updated.map((e) => e.toJson()).toList();
                              });
                              await _saveSections();
                            },
                          );
                          
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );

    return Column(
      children: [
        calendar,
        Expanded(child: list),
      ],
    );
  }

  Widget _buildCalendar(List<Map<String, dynamic>> upcoming) {
    // build a set of dates that have events (year-month-day string)
    final Set<String> daysWithEvents = {};
    for (final it in upcoming) {
      final DateTime d = it['nextDate'];
      daysWithEvents.add('${d.year}-${d.month}-${d.day}');
    }

    int year = _displayYear;
    int month = _displayMonth;

    int daysInMonth(int y, int m) {
      final next = m == 12 ? DateTime(y + 1, 1, 1) : DateTime(y, m + 1, 1);
      return next.subtract(const Duration(days: 1)).day;
    }

    final firstWeekday = DateTime(year, month, 1).weekday; // 1..7
    final totalDays = daysInMonth(year, month);

    // weekday headers
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    int day = 1;
    // rows
    List<TableRow> rows = [];
    List<Widget> currentRow = [];

    // fill initial empty slots (firstWeekday: Monday=1)
    int leadingEmpty = firstWeekday - 1;
    for (int i = 0; i < leadingEmpty; i++) {
      currentRow.add(Container());
    }

    while (day <= totalDays) {
      final key = '$year-$month-$day';
      final has = daysWithEvents.contains(key);
      final cell = GestureDetector(
        onTap: has
            ? () {
                // TODO: navigate to event(s) on this date
              }
            : null,
        child: Container(
          margin: const EdgeInsets.all(4),
          height: 48,
          decoration: has
              ? BoxDecoration(color: Colors.deepPurple.withOpacity(0.12), borderRadius: BorderRadius.circular(8))
              : null,
          child: Center(
            child: has
                ? Column(mainAxisSize: MainAxisSize.min, children: [Text('$day', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 2), const Icon(Icons.circle, size: 8, color: Colors.deepPurple)])
                : Text('$day'),
          ),
        ),
      );

      currentRow.add(cell);

      if (currentRow.length == 7) {
        rows.add(TableRow(children: currentRow));
        currentRow = [];
      }

      day++;
    }

    // fill trailing empty
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(Container());
      }
      rows.add(TableRow(children: currentRow));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () { setState(() { if (_displayMonth==1) { _displayMonth=12; _displayYear--; } else _displayMonth--; }); }, icon: const Icon(Icons.chevron_left)),
              Text('${monthName(month)} $year', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () { setState(() { if (_displayMonth==12) { _displayMonth=1; _displayYear++; } else _displayMonth++; }); }, icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 6),
          // weekday header
          Row(children: weekdays.map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold))))).toList()),
          const SizedBox(height: 6),
          Table(children: rows),
        ],
      ),
    );
  }

  String monthName(int m) {
    const names = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return names[m-1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: _buildDrawer(),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        title: const Text(
          "Spacenote",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _buildBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSectionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}