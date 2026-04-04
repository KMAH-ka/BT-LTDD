import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/sinhvien.dart';

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sinhviens(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL
          )
        ''');
      },
    );
  }

  // Thêm sinh viên
  Future<int> insertSinhVien(SinhVien sv) async {
    final db = await database;
    return await db.insert(
      'sinhviens',
      sv.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lấy tất cả sinh viên
  Future<List<SinhVien>> getSinhViens() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sinhviens');
    return List.generate(
      maps.length,
          (i) => SinhVien.fromMap(maps[i]),
    );
  }

  // Cập nhật sinh viên
  Future<int> updateSinhVien(SinhVien sv) async {
    final db = await database;
    return await db.update(
      'sinhviens',
      sv.toMap(),
      where: 'id = ?',
      whereArgs: [sv.id],
    );
  }

  // Xóa sinh viên
  Future<int> deleteSinhVien(int id) async {
    final db = await database;
    return await db.delete(
      'sinhviens',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}