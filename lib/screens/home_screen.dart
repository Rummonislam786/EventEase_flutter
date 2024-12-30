import 'package:calendar_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Initialize selected day
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

  String _formatTime(DateTime time) {
    final formatter =
        DateFormat('h:mm a'); // This will format time as "1:30 PM"
    return formatter.format(time);
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
                child: Builder(
                  builder: (context) {
                    if (_selectedDay == null) return const SizedBox.shrink();

                    final eventsForDay = _getEventsForDay(
                      _selectedDay!,
                      eventProvider.events,
                    );

                    if (eventsForDay.isEmpty) {
                      return Center(
                        child: Text(
                          'No events for ${DateFormat('MMMM d, yyyy').format(_selectedDay!)}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: eventsForDay.length,
                      itemBuilder: (context, index) {
                        final event = eventsForDay[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(
                              event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: event.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                                ),
                                // if (event.location != null &&
                                //     event.location!.isNotEmpty)
                                //   Text(
                                //     '📍 ${event.location}',
                                //     style: TextStyle(color: Colors.grey[600]),
                                //   ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (event.todos.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      '${event.todos.where((todo) => todo.completed).length}/${event.todos.length}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                Checkbox(
                                  value: event.completed,
                                  onChanged: (bool? value) async {
                                    final updatedEvent = event.copyWith(
                                      completed: value ?? false,
                                    );
                                    await eventProvider
                                        .updateEvent(updatedEvent);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailScreen(
                                    event: event,
                                  ),
                                ),
                              ).then((_) {
                                // Refresh events when returning from details
                                eventProvider.fetchEvents();
                              });
                            },
                          ),
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
              builder: (context) => const AddEditEventScreen(),
            ),
          ).then((_) {
            // Refresh events when returning from add screen
            Provider.of<EventProvider>(context, listen: false).fetchEvents();
          });
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
