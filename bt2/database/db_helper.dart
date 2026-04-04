import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/sinhvien.dart';
import '../model/todo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'app_qlsv.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Bảng sinh viên
        await db.execute('''
          CREATE TABLE sinhviens(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL
          )
        ''');
        // Bảng todo
        await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            isDone INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS todos(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              isDone INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
      },
    );
  }

  // ===================== SINH VIEN =====================

  Future<int> insertSinhVien(SinhVien sv) async {
    final db = await database;
    return await db.insert('sinhviens', sv.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SinhVien>> getSinhViens() async {
    final db = await database;
    final maps = await db.query('sinhviens');
    return maps.map((m) => SinhVien.fromMap(m)).toList();
  }

  Future<int> updateSinhVien(SinhVien sv) async {
    final db = await database;
    return await db.update('sinhviens', sv.toMap(),
        where: 'id = ?', whereArgs: [sv.id]);
  }

  Future<int> deleteSinhVien(int id) async {
    final db = await database;
    return await db.delete('sinhviens', where: 'id = ?', whereArgs: [id]);
  }

  // ===================== TODO =====================

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final maps = await db.query('todos', orderBy: 'id DESC');
    return maps.map((m) => Todo.fromMap(m)).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update('todos', todo.toMap(),
        where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}