class Event {
  int? id;
  String title;
  String? description;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String? location;
  bool completed;
  List<Todo> todos; // New field

  Event({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.completed = false,
    this.todos = const [], // Initialize empty list
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

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? completed,
    List<Todo>? todos,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      completed: completed ?? this.completed,
      todos: todos ?? this.todos,
    );
  }
}

class Todo {
  int? id;
  int eventId;
  String task;
  bool completed;

  Todo({
    this.id,
    required this.eventId,
    required this.task,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'task': task,
      'completed': completed ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      eventId: map['event_id'],
      task: map['task'],
      completed: map['completed'] == 1,
    );
  }
  Todo copyWith({
    int? id,
    int? eventId,
    String? task,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      task: task ?? this.task,
      completed: completed ?? this.completed,
    );
  }
}
