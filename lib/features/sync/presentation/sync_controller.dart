import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../records/data/records_repository.dart';
import '../../records/domain/record_entity.dart';
import '../domain/sync_repository.dart';
import '../data/sync_repository_impl.dart';
import '../data/supabase_sync_repository.dart';
import '../../../core/network/supabase_client.dart';

class SyncState {
  final bool syncing;
  final String? error;

  const SyncState({this.syncing = false, this.error});
}

class SyncController extends StateNotifier<SyncState> {
  SyncController(this._recordsRepo, this._syncRepo) : super(const SyncState()) {
    _init();
  }

  final RecordsRepository _recordsRepo;
  final SyncRepository _syncRepo;
  StreamSubscription? _subscription;

  void _init() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncPending();
      }
    });
  }

  Future<void> syncPending() async {
    if (state.syncing) return;
    state = const SyncState(syncing: true);
    try {
      final pending = await _recordsRepo.getPendingSync();
      for (final item in pending) {
        final recordId = item['record_id'] as int;
        final recordRows = await _recordsRepo.getRecords();
        final record = recordRows.firstWhere((r) => r.id == recordId);
        final remoteId = await _syncRepo.syncRecord(record);
        final media = await _recordsRepo.getMediaByRecord(recordId);
        for (final m in media) {
          final exists = await File(m.path).exists();
          if (!exists) continue;
          if (m.type == MediaType.image) {
            await _syncRepo.uploadImage(remoteId, m.path);
          } else if (m.type == MediaType.audio) {
            await _syncRepo.uploadAudio(remoteId, m.path);
          } else if (m.type == MediaType.signature) {
            await _syncRepo.uploadSignature(remoteId, m.path);
          }
        }
        await _recordsRepo.removePendingSync(item['id'] as int);
      }
      state = const SyncState(syncing: false);
    } catch (e) {
      state = SyncState(syncing: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>((ref) {
  return SyncController(ref.watch(recordsRepositoryProvider), ref.watch(supabaseSyncRepositoryProvider));
});

final supabaseSyncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SupabaseSyncRepository(ref.read(supabaseProvider));
});
