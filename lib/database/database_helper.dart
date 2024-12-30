import 'package:calendar_app/Models/users.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();
  final databaseName = 'offline_calendar.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    // If you're testing and need to ensure the database is recreated,
    // you can delete it first:
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 2, // Increment version number since we're adding a new table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        UserID INTEGER PRIMARY KEY AUTOINCREMENT,
        UserName TEXT UNIQUE,
        UserEmail TEXT,
        UserPassword TEXT
      )
    ''');

    // Create events table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        location TEXT,
        completed INTEGER DEFAULT 0
      )
    ''');

    // Create todos table
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        task TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create todos table if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          event_id INTEGER NOT NULL,
          task TEXT NOT NULL,
          completed INTEGER DEFAULT 0,
          FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<bool> _todoTableExists() async {
    final db = await database;
    final tables = await db.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: ['table', 'todos'],
    );
    return tables.isNotEmpty;
  }

  Future<void> ensureTodosTable() async {
    final db = await database;
    final todoTableExists = await _todoTableExists();

    if (!todoTableExists) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          event_id INTEGER NOT NULL,
          task TEXT NOT NULL,
          completed INTEGER DEFAULT 0,
          FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<int> insertTodo(Todo todo) async {
    await ensureTodosTable();
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  // Future<int> insertTodo(Todo todo) async {
  //   final db = await database;
  //   return await db.insert('todos', todo.toMap());
  // }

  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Todo>> getTodosForEvent(int eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<bool> login(Users user) async {
    final Database db = await instance.database;
    // I forgot the password to check
    var result = await db.rawQuery(
        "select * from users where UserName = '${user.username}' AND UserPassword = '${user.password}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> createUser(Users user) async {
    final Database db = await instance.database;
    return db.insert('users', user.toMap());
  }

  //CRUD Methods

  //Get notes
  Future<List<Users>> getUsers() async {
    final Database db = await instance.database;
    List<Map<String, Object?>> result = await db.query('users');
    return result.map((e) => Users.fromMap(e)).toList();
  }

  //Delete Notes
  Future<int> deleteUser(int id) async {
    final Database db = await instance.database;
    return db.delete('users', where: 'UserID = ?', whereArgs: [id]);
  }

  //Update Notes
  Future<int> updateUser(username, password, email) async {
    final Database db = await instance.database;
    return db.rawUpdate(
        'update users set UserName = ?, UserPassword = ?, UserEmail where noteId = ?',
        [username, password, email]);
  }

  Future<int> signup(Users user) async {
    final Database db = await instance.database;
    return db.insert('users', user.toMap());
  }

  Future<List<Users>> searchUsers(String keyword) async {
    final Database db = await instance.database;
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from users where UserName LIKE ${"%$keyword%"} or UserEmail LIKE ${"%$keyword%"} or UserID LIKE ${"%$keyword%"}");
    return searchResult.map((e) => Users.fromMap(e)).toList();
  }

  // Create (Insert) Event
  Future<Event> create(Event event) async {
    final db = await instance.database;
    final id = await db.insert('events', event.toMap());
    for (var todo in event.todos) {
      todo = todo.copyWith(eventId: id);
      await insertTodo(todo);
    }
    return event.copyWith(id: id);
  }

  // Read All Events
  Future<List<Event>> readAllEvents() async {
    final db = await instance.database;
    const orderBy = 'date ASC';
    final result = await db.query('events', orderBy: orderBy);
    return result.map((json) => Event.fromMap(json)).toList();
  }

  Future<Event> readEvent(int id) async {
    final db = await database;
    final maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Event not found');
    }

    Event event = Event.fromMap(maps.first);
    // Load todos for this event
    event.todos = await getTodosForEvent(id);
    return event;
  }

  // Read Events by Date
  Future<List<Event>> readEventsByDate(DateTime date) async {
    final db = await instance.database;
    final result = await db.query('events',
        where: 'date = ?', whereArgs: [date.toIso8601String().split('T')[0]]);
    return result.map((json) => Event.fromMap(json)).toList();
  }

  // Update Event
  Future<int> update(Event event) async {
    final db = await database;

    // Update event
    final result = await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );

    // Update todos
    for (var todo in event.todos) {
      if (todo.id != null) {
        await updateTodo(todo);
      } else {
        todo = todo.copyWith(eventId: event.id);
        await insertTodo(todo);
      }
    }

    return result;
  }

  // Delete Event
  Future<int> delete(int id) async {
    final db = await database;
    // Due to CASCADE delete, todos will be automatically deleted
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // Search Events
  Future<List<Event>> searchEvents(String query) async {
    final db = await instance.database;
    final result = await db.query('events',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%']);
    return result.map((json) => Event.fromMap(json)).toList();
  }
}

extension EventExtension on Event {
  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? completed,
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
    );
  }
}
