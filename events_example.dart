import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

///
/// The Event class represents a calendar entry.
///
class Event {
  final String title;
  final DateTime start;
  final DateTime end;
  const Event(this.title, this.start, this.end);

  @override
  String toString() =>
      "$title ${start.hour}:${start.minute.toString().padLeft(2, "0")} - ${end.hour}:${end.minute.toString().padLeft(2, "0")}";
  //What are we overriding? nothing is being extended...?
}

///
/// ALL_EVENTS is where we put all our events. It is like a dictionary.
/// Each Date/Time is mapped to a list of events that happen on that day
///
final ALL_EVENTS = LinkedHashMap<DateTime, List<Event>>(
  equals:
      isSameDay, // we have to tell the map how to tell if two DateTimes are on the same day
  hashCode: getHashCode,
);

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final today = DateTime.now();
final startOfCalendar = DateTime(today.year, today.month - 3, today.day);
final endOfCalendar = DateTime(today.year, today.month + 3, today.day);

class TableEventsExample extends StatefulWidget {
  DateTime focusedDay;
  TableEventsExample({Key? key, required this.focusedDay}) : super(key: key);

  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  //Sets the day that the calendar focuses when opened
  DateTime? _selectedDay;

  @override
  void initState() {
    _focusedDay = widget.focusedDay;
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return ALL_EVENTS[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Event>(
          firstDay: startOfCalendar,
          lastDay: endOfCalendar,
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          eventLoader: _getEventsForDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => print('${value[index]}'),
                      title: Text('${value[index]}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
