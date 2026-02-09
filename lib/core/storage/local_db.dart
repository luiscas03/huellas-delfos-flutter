import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static const _dbName = 'huellas.db';
  static const _dbVersion = 1;
  static final LocalDb instance = LocalDb._();
  LocalDb._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final basePath = await getDatabasesPath();
    final path = p.join(basePath, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            remote_id TEXT,
            status TEXT,
            created_at TEXT,
            patient_id TEXT,
            patient_name TEXT,
            payload TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE record_media (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            record_id INTEGER,
            type TEXT,
            path TEXT,
            duration_ms INTEGER,
            FOREIGN KEY (record_id) REFERENCES records (id)
          );
        ''');
        await db.execute('''
          CREATE TABLE pending_sync (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            record_id INTEGER,
            payload TEXT,
            last_error TEXT,
            retry_count INTEGER
          );
        ''');
      },
    );
    return _db!;
  }
}
