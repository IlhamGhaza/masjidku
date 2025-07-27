import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('masjidku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmark(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surat TEXT NOT NULL,
        suratNumber INTEGER NOT NULL,
        ayatNumber INTEGER NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadith_bookmark(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hadith_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        chapter_id INTEGER NOT NULL,
        hadith_text TEXT NOT NULL,
        narrator TEXT NOT NULL,
        reference TEXT NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
