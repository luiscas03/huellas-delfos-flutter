import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_tables.dart';
import '../../records/domain/record_entity.dart';
import '../domain/sync_repository.dart';

class SupabaseSyncRepository implements SyncRepository {
  SupabaseSyncRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<String> syncRecord(RecordEntity record) async {
    final payload = Map<String, dynamic>.from(record.payload);
    if (payload['local_files'] is Map) {
      final local = payload['local_files'] as Map;
      final session = Map<String, dynamic>.from(payload['session'] as Map? ?? {});
      final recordId = DateTime.now().millisecondsSinceEpoch.toString();

      if (local['audio'] is List && (local['audio'] as List).isNotEmpty) {
        final audioUrls = <String>[];
        for (final path in (local['audio'] as List)) {
          final url = await _uploadToBucket(SupabaseBuckets.audio, path.toString(), recordId);
          if (url != null) audioUrls.add(url);
        }
        session['audio_url'] = audioUrls.isNotEmpty ? audioUrls.first : null;
        final segments = (session['audio_segments'] as List? ?? []).cast<Map<String, dynamic>>();
        if (segments.isNotEmpty && audioUrls.length == segments.length) {
          for (var i = 0; i < segments.length; i++) {
            segments[i] = {...segments[i], 'url': audioUrls[i]};
          }
          session['audio_segments'] = segments;
        }
      }
      if (local['images'] is List) {
        final urls = <String>[];
        for (final path in (local['images'] as List)) {
          final url = await _uploadToBucket(SupabaseBuckets.visitPhotos, path.toString(), recordId);
          if (url != null) urls.add(url);
        }
        session['photos_urls'] = urls;
      }
      if (local['signature'] is String && (local['signature'] as String).isNotEmpty) {
        final url = await _uploadToBucket(SupabaseBuckets.signatures, local['signature'] as String, recordId);
        session['signature_url'] = url;
      }

      payload['session'] = session;
      payload.remove('local_files');
    }

    final res = await _client.functions.invoke('save-visit', body: payload);
    final data = res.data as Map<String, dynamic>;
    return data['session_id'].toString();
  }

  @override
  Future<void> uploadAudio(String recordRemoteId, String filePath) async {
    await _uploadToBucket(SupabaseBuckets.audio, filePath, recordRemoteId);
  }

  @override
  Future<void> uploadImage(String recordRemoteId, String filePath) async {
    await _uploadToBucket(SupabaseBuckets.visitPhotos, filePath, recordRemoteId);
  }

  @override
  Future<void> uploadSignature(String recordRemoteId, String filePath) async {
    await _uploadToBucket(SupabaseBuckets.signatures, filePath, recordRemoteId);
  }

  Future<String?> _uploadToBucket(String bucket, String filePath, String folder) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    final fileName = p.basename(filePath);
    final objectPath = '$folder/$fileName';
    await _client.storage.from(bucket).upload(objectPath, file, fileOptions: const FileOptions(upsert: true));
    return _client.storage.from(bucket).getPublicUrl(objectPath);
  }
}
