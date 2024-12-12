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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    String users =
        "create table users (UserID INTEGER PRIMARY KEY AUTOINCREMENT, UserName TEXT UNIQUE, UserEmail Text, UserPassword TEXT)";

    await db.execute(users);

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
    return event.copyWith(id: id);
  }

  // Read All Events
  Future<List<Event>> readAllEvents() async {
    final db = await instance.database;
    const orderBy = 'date ASC';
    final result = await db.query('events', orderBy: orderBy);
    return result.map((json) => Event.fromMap(json)).toList();
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
    final db = await instance.database;
    return db.update('events', event.toMap(),
        where: 'id = ?', whereArgs: [event.id]);
  }

  // Delete Event
  Future<int> delete(int id) async {
    final db = await instance.database;
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
