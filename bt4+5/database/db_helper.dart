import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/nguoidung.dart';
import '../model/chitieu.dart';

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
    String path = join(await getDatabasesPath(), 'app_chitieu.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Bảng người dùng
        await db.execute('''
          CREATE TABLE nguoidungs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');
        // Bảng chi tiêu
        await db.execute('''
          CREATE TABLE chitieux(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            noiDung TEXT NOT NULL,
            soTien REAL NOT NULL,
            ghiChu TEXT,
            nguoiDungId INTEGER NOT NULL,
            FOREIGN KEY (nguoiDungId) REFERENCES nguoidungs(id)
          )
        ''');
      },
    );
  }

  // ===================== NGUOI DUNG =====================

  Future<int> registerNguoiDung(NguoiDung nd) async {
    final db = await database;
    try {
      return await db.insert('nguoidungs', nd.toMap());
    } catch (e) {
      return -1; // email đã tồn tại
    }
  }

  Future<NguoiDung?> loginNguoiDung(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      'nguoidungs',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isEmpty) return null;
    return NguoiDung.fromMap(maps.first);
  }

  // ===================== CHI TIEU =====================

  Future<int> insertChiTieu(ChiTieu ct) async {
    final db = await database;
    return await db.insert('chitieux', ct.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChiTieu>> getChiTieus(int nguoiDungId) async {
    final db = await database;
    final maps = await db.query(
      'chitieux',
      where: 'nguoiDungId = ?',
      whereArgs: [nguoiDungId],
      orderBy: 'id DESC',
    );
    return maps.map((m) => ChiTieu.fromMap(m)).toList();
  }

  Future<int> updateChiTieu(ChiTieu ct) async {
    final db = await database;
    return await db.update('chitieux', ct.toMap(),
        where: 'id = ?', whereArgs: [ct.id]);
  }

  Future<int> deleteChiTieu(int id) async {
    final db = await database;
    return await db.delete('chitieux', where: 'id = ?', whereArgs: [id]);
  }
}