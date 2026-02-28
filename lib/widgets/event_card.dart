import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../core/utils/date_utils.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        DateUtilsHelper.daysRemaining(event.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.grey.withOpacity(0.1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          /// Date
          Text(
            "Date: ${event.date.toLocal().toString().split(' ')[0]}"),

          /// Countdown
          Text(
            daysLeft >= 0
                ? "⏳ $daysLeft days remaining"
                : "⚠️ Expired",
            style: TextStyle(
              color: daysLeft < 0 ? Colors.red : Colors.green,
            ),
          ),

          /// Recurrence
          Text("🔁 ${event.recurrence}"),
        ],
      ),
    );
  }
}