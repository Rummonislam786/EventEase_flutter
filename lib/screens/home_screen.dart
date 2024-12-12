import 'package:calendar_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import 'add_edit_event_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // ignore: unused_field
  List<Event> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    // Fetch events when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
    });
  }

  // Helper method to get events for a specific day
  List<Event> _getEventsForDay(DateTime day, List<Event> events) {
    return events
        .where((event) =>
            event.date.year == day.year &&
            event.date.month == day.month &&
            event.date.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: EventSearchDelegate());
            },
          )
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          return Column(
            children: [
              // Calendar View
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEvents =
                          _getEventsForDay(selectedDay, eventProvider.events);
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  return _getEventsForDay(day, eventProvider.events);
                },
              ),

              // Events List for Selected Day
              Expanded(
                child: Consumer<EventProvider>(
                  builder: (context, eventProvider, child) {
                    // Use the provider's events list instead of _selectedEvents
                    final displayEvents = eventProvider.events
                        .where((e) => isSameDay(e.date, _selectedDay))
                        .toList();

                    return displayEvents.isEmpty
                        ? Center(
                            child: Text(
                              'No events for this day',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayEvents.length,
                            itemBuilder: (context, index) {
                              final event = displayEvents[index];
                              return ListTile(
                                title: Text(event.title),
                                subtitle: Text(
                                    '${event.startTime.hour}:${event.startTime.minute} - '
                                    '${event.endTime.hour}:${event.endTime.minute}'),
                                trailing: Checkbox(
                                  value: event.completed,
                                  onChanged: (bool? value) {
                                    // Toggle event completion
                                    final updatedEvent = event.copyWith(
                                        completed: value ?? false);
                                    eventProvider.updateEvent(updatedEvent);
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EventDetailScreen(event: event)));
                                },
                              );
                            },
                          );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddEditEventScreen()));
        },
      ),
    );
  }
}

// Custom Search Delegate for Events
class EventSearchDelegate extends SearchDelegate<Event?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return FutureBuilder<List<Event>>(
      future: eventProvider.searchEvents(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No events found'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final event = snapshot.data![index];
            return ListTile(
              title: Text(event.title),
              subtitle: Text('${event.date.toLocal()} | '
                  '${event.startTime.hour}:${event.startTime.minute}'),
              onTap: () {
                // Navigate to event detail or return selected event
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event)));
              },
            );
          },
        );
      },
    );
  }
}
