import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../database/database_helper.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<Event> get events => _events;

  Future<void> fetchEvents() async {
    try {
      // Fetch all events from the database
      _events = await DatabaseHelper.instance.readAllEvents();

      // Notify listeners that the events have been updated
      notifyListeners();

      if (kDebugMode) {
        print('Events fetched: ${_events.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching events: $e');
      }
      // Handle the error appropriately
    }
  }

  Future<void> addEvent(Event event) async {
    await DatabaseHelper.instance.create(event);
    await fetchEvents();
  }

  Future<void> updateEvent(Event event) async {
    try {
      // Update the event in the database
      await DatabaseHelper.instance.update(event);

      // Refresh the events list
      await fetchEvents();

      // Optional: Add some error handling and logging
      if (kDebugMode) {
        print('Event updated successfully: ${event.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating event: $e');
      }
      // Optionally, you might want to rethrow the error
      // or handle it in a way that makes sense for your app
    }
  }

  Future<void> deleteEvent(int id) async {
    await DatabaseHelper.instance.delete(id);
    await fetchEvents();
  }

  Future<List<Event>> getEventsByDate(DateTime date) async {
    return await DatabaseHelper.instance.readEventsByDate(date);
  }

  Future<List<Event>> searchEvents(String query) async {
    return await DatabaseHelper.instance.searchEvents(query);
  }

  // Helper methods for UI
  List<Event> getEventsForMonth(DateTime month) {
    return _events
        .where((event) =>
            event.date.year == month.year && event.date.month == month.month)
        .toList();
  }

  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((event) => event.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
