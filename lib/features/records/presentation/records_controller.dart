import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../data/records_repository.dart';
import '../domain/record_entity.dart';

class RecordsState {
  final List<RecordEntity> records;
  final bool loading;
  final String? error;

  const RecordsState({
    required this.records,
    this.loading = false,
    this.error,
  });

  RecordsState copyWith({
    List<RecordEntity>? records,
    bool? loading,
    String? error,
  }) {
    return RecordsState(
      records: records ?? this.records,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class RecordsController extends StateNotifier<RecordsState> {
  RecordsController(this._repo) : super(const RecordsState(records: [])) {
    load();
  }

  final RecordsRepository _repo;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final records = await _repo.getRecords();
      state = state.copyWith(records: records, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<int> createRecord(RecordEntity record) async {
    final id = await _repo.insertRecord(record);
    await load();
    return id;
  }

  Future<void> addMedia({
    required int recordId,
    required MediaType type,
    required File file,
    int? durationMs,
  }) async {
    final saved = await _copyToRecordFolder(recordId, type, file);
    await _repo.insertMedia(
      RecordMedia(recordId: recordId, type: type, path: saved.path, durationMs: durationMs),
    );
  }

  Future<List<RecordMedia>> getMedia(int recordId) async {
    return _repo.getMediaByRecord(recordId);
  }

  Future<void> addPendingSync(int recordId, Map<String, dynamic> payload) async {
    await _repo.addPendingSync(recordId, payload);
  }

  Future<File> _copyToRecordFolder(int recordId, MediaType type, File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final typeFolder = type == MediaType.image
        ? 'images'
        : type == MediaType.audio
            ? 'audios'
            : 'signature';
    final recordDir = Directory(p.join(dir.path, 'records', '$recordId', typeFolder));
    if (!await recordDir.exists()) {
      await recordDir.create(recursive: true);
    }
    final fileName = p.basename(file.path);
    final target = File(p.join(recordDir.path, fileName));
    return file.copy(target.path);
  }
}

final recordsControllerProvider = StateNotifierProvider<RecordsController, RecordsState>((ref) {
  return RecordsController(ref.watch(recordsRepositoryProvider));
});
