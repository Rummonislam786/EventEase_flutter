class Event {
  int? id;
  String title;
  String? description;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String? location;
  bool completed;

  Event({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.completed = false,
  });

  // Convert Event to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'completed': completed ? 1 : 0,
    };
  }

  // Create Event from Map retrieved from database
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      location: map['location'],
      completed: map['completed'] == 1,
    );
  }

  // Validate event details
  bool isValid() {
    return title.isNotEmpty &&
        startTime.isBefore(endTime) &&
        date.isBefore(DateTime.now().add(const Duration(days: 365 * 10)));
  }
}
