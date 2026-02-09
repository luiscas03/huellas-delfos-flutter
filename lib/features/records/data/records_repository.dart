import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/storage/local_db.dart';
import '../domain/record_entity.dart';

class RecordsRepository {
  Future<int> insertRecord(RecordEntity record) async {
    final db = await LocalDb.instance.database;
    return db.insert('records', record.toMap());
  }

  Future<void> updateRecord(RecordEntity record) async {
    final db = await LocalDb.instance.database;
    await db.update('records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<List<RecordEntity>> getRecords() async {
    final db = await LocalDb.instance.database;
    final rows = await db.query('records', orderBy: 'created_at DESC');
    return rows.map(RecordEntity.fromMap).toList();
  }

  Future<int> insertMedia(RecordMedia media) async {
    final db = await LocalDb.instance.database;
    return db.insert('record_media', media.toMap());
  }

  Future<List<RecordMedia>> getMediaByRecord(int recordId) async {
    final db = await LocalDb.instance.database;
    final rows = await db.query('record_media', where: 'record_id = ?', whereArgs: [recordId]);
    return rows.map(RecordMedia.fromMap).toList();
  }

  Future<void> addPendingSync(int recordId, Map<String, dynamic> payload) async {
    final db = await LocalDb.instance.database;
    await db.insert('pending_sync', {
      'record_id': recordId,
      'payload': payload.toString(),
      'last_error': null,
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final db = await LocalDb.instance.database;
    return db.query('pending_sync');
  }

  Future<void> updatePendingSync(int id, {String? lastError, int? retryCount}) async {
    final db = await LocalDb.instance.database;
    await db.update('pending_sync', {
      if (lastError != null) 'last_error': lastError,
      if (retryCount != null) 'retry_count': retryCount,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removePendingSync(int id) async {
    final db = await LocalDb.instance.database;
    await db.delete('pending_sync', where: 'id = ?', whereArgs: [id]);
  }
}

final recordsRepositoryProvider = Provider<RecordsRepository>((ref) {
  return RecordsRepository();
});
