import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/sanpham.dart';

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
    String path = join(await getDatabasesPath(), 'app_sanpham.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sanphams(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ma TEXT NOT NULL,
            ten TEXT NOT NULL,
            gia REAL NOT NULL,
            giamGia REAL NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertSanPham(SanPham sp) async {
    final db = await database;
    return await db.insert('sanphams', sp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SanPham>> getSanPhams() async {
    final db = await database;
    final maps = await db.query('sanphams', orderBy: 'id DESC');
    return maps.map((m) => SanPham.fromMap(m)).toList();
  }

  Future<int> updateSanPham(SanPham sp) async {
    final db = await database;
    return await db.update('sanphams', sp.toMap(),
        where: 'id = ?', whereArgs: [sp.id]);
  }

  Future<int> deleteSanPham(int id) async {
    final db = await database;
    return await db.delete('sanphams', where: 'id = ?', whereArgs: [id]);
  }
}