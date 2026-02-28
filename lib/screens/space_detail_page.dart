import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../core/utils/date_utils.dart';

class SpaceDetailPage extends StatefulWidget {
  final String spaceName;
  final List<EventModel> events;

  const SpaceDetailPage({
    super.key,
    required this.spaceName,
    required this.events,
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
    String recurrence = "none";

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
                    value: recurrence,
                    items: const [
                      DropdownMenuItem(
                        value: "none",
                        child: Text("No recurrence"),
                      ),
                      DropdownMenuItem(
                        value: "daily",
                        child: Text("Daily"),
                      ),
                      DropdownMenuItem(
                        value: "monthly",
                        child: Text("Monthly"),
                      ),
                      DropdownMenuItem(
                        value: "yearly",
                        child: Text("Yearly"),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          recurrence = v;
                        });
                      }
                    },
                  ),
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

                    setState(() {
                      events.add(
                        EventModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          date: selectedDate,
                          recurrence: recurrence,
                        ),
                      );
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

        final daysLeft =
            DateUtilsHelper.daysRemaining(event.date);

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(event.title),

            subtitle: Text(
              daysLeft >= 0
                  ? "⏳ $daysLeft days remaining"
                  : "⚠️ Expired",
              style: TextStyle(
                  color: daysLeft < 0 ? Colors.red : Colors.green),
            ),

            trailing: Text(event.recurrence),
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