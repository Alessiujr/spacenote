import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../core/utils/date_utils.dart';

class SpaceDetailPage extends StatefulWidget {
  final String spaceName;
  final List<EventModel> events;
  final ValueChanged<List<EventModel>>? onEventsChanged;

  const SpaceDetailPage({
    super.key,
    required this.spaceName,
    required this.events,
    this.onEventsChanged,
  });

  @override
  State<SpaceDetailPage> createState() => _SpaceDetailPageState();
}

class _SpaceDetailPageState extends State<SpaceDetailPage> {
  late List<EventModel> events;

  @override
  void initState() {
    super.initState();
    events = List.from(widget.events);
  }

  void _addEventDialog() {
    final titleController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    String costInput = '';
    String? costError;
    String freq = "none";
    String monthlyMode = 'day';
    int dayOfMonth = selectedDate.day;
    int nth = 1; // for nth_weekday
    int nthWeekday = DateTime.monday;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Event"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: "Event title"),
                  ),

                  const SizedBox(height: 15),

                  /// Date picker
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: selectedDate,
                      );

                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: const Text("Select Date"),
                  ),

                  const SizedBox(height: 10),

                  DropdownButton<String>(
                    value: freq,
                    items: const [
                      DropdownMenuItem(value: "none", child: Text("No recurrence")),
                      DropdownMenuItem(value: "daily", child: Text("Daily")),
                      DropdownMenuItem(value: "weekly", child: Text("Weekly")),
                      DropdownMenuItem(value: "monthly", child: Text("Monthly")),
                      DropdownMenuItem(value: "yearly", child: Text("Yearly")),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          freq = v;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 8),

                  // Advanced monthly options
                  if (freq == 'monthly') ...[
                    const Text('Monthly options:'),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      value: monthlyMode,
                      items: const [
                        DropdownMenuItem(value: 'day', child: Text('Day of month')),
                        DropdownMenuItem(value: 'first_business_day', child: Text('First business day')),
                        DropdownMenuItem(value: 'last_business_day', child: Text('Last business day')),
                        DropdownMenuItem(value: 'nth_weekday', child: Text('Nth weekday (e.g. 1st Monday)')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            monthlyMode = v;
                          });
                        }
                      },
                    ),

                    if (monthlyMode == 'day') ...[
                      const SizedBox(height: 6),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Day of month', hintText: '$dayOfMonth'),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed >= 1 && parsed <= 31) {
                            dayOfMonth = parsed;
                          }
                        },
                      ),
                    ],

                    if (monthlyMode == 'nth_weekday') ...[
                      const SizedBox(height: 6),
                      DropdownButton<int>(
                        value: nth,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1st')),
                          DropdownMenuItem(value: 2, child: Text('2nd')),
                          DropdownMenuItem(value: 3, child: Text('3rd')),
                          DropdownMenuItem(value: 4, child: Text('4th')),
                          DropdownMenuItem(value: -1, child: Text('Last')),
                        ],
                        onChanged: (v) {
                          if (v != null) setDialogState(() => nth = v);
                        },
                      ),
                      DropdownButton<int>(
                        value: nthWeekday,
                        items: const [
                          DropdownMenuItem(value: DateTime.monday, child: Text('Mon')),
                          DropdownMenuItem(value: DateTime.tuesday, child: Text('Tue')),
                          DropdownMenuItem(value: DateTime.wednesday, child: Text('Wed')),
                          DropdownMenuItem(value: DateTime.thursday, child: Text('Thu')),
                          DropdownMenuItem(value: DateTime.friday, child: Text('Fri')),
                          DropdownMenuItem(value: DateTime.saturday, child: Text('Sat')),
                          DropdownMenuItem(value: DateTime.sunday, child: Text('Sun')),
                        ],
                        onChanged: (v) {
                          if (v != null) setDialogState(() => nthWeekday = v);
                        },
                      ),
                    ],
                  ],

                  const SizedBox(height: 12),
                  // Optional cost (placed at bottom of dialog)
                  TextField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Optional cost', hintText: 'e.g. 9 or 9.99'),
                    onChanged: (v) => setDialogState(() {
                      costInput = v;
                      costError = null;
                    }),
                  ),
                  if (costError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      costError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) return;
                    // validate cost format (optional)
                    double? parsedCost;
                    if (costInput.trim().isNotEmpty) {
                      parsedCost = double.tryParse(costInput.replaceAll(',', '.'));
                      if (parsedCost == null) {
                        setDialogState(() {
                          costError = 'Formato errato';
                        });
                        return;
                      }
                    }

                    // build recurrence rule
                    RecurrenceRule rr;
                    if (freq == 'none') {
                      rr = RecurrenceRule.none();
                    } else if (freq == 'monthly') {
                      MonthlyRule mr;
                      if (monthlyMode == 'day') {
                        mr = MonthlyRule(mode: 'day', dayOfMonth: dayOfMonth);
                      } else if (monthlyMode == 'first_business_day') {
                        mr = MonthlyRule(mode: 'first_business_day');
                      } else if (monthlyMode == 'last_business_day') {
                        mr = MonthlyRule(mode: 'last_business_day');
                      } else {
                        mr = MonthlyRule(mode: 'nth_weekday', nth: nth, weekday: nthWeekday);
                      }

                      rr = RecurrenceRule(frequency: 'monthly', monthlyRule: mr);
                    } else {
                      rr = RecurrenceRule(frequency: freq);
                    }

                    setState(() {
                      events.add(
                        EventModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          date: selectedDate,
                          recurrence: rr,
                          cost: parsedCost,
                        ),
                      );

                      // notify parent to persist
                      widget.onEventsChanged?.call(events);
                    });

                    Navigator.pop(context);
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

  Widget _buildEventList() {
    if (events.isEmpty) {
      return const Center(
        child: Text("No events yet"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        final nextDate = DateUtilsHelper.nextOccurrence(event.date, event.recurrence);
        final daysLeft = DateUtilsHelper.daysRemaining(nextDate);

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(event.title),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next: ${nextDate.day}/${nextDate.month}/${nextDate.year}'),
                const SizedBox(height: 4),
                Text(event.recurrence.toReadableString()),
                const SizedBox(height: 6),
                Text(
                  daysLeft >= 0 ? "⏳ $daysLeft days remaining" : "⚠️ Expired",
                  style: TextStyle(color: daysLeft < 0 ? Colors.red : Colors.green),
                ),
              ],
            ),

            trailing: event.cost != null
                ? Text('€' + event.cost!.toStringAsFixed(2))
                : const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spaceName),
      ),

      body: _buildEventList(),

      floatingActionButton: FloatingActionButton(
        onPressed: _addEventDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}