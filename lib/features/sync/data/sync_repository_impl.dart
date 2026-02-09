import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/network/dio_client.dart';
import '../../records/domain/record_entity.dart';
import '../domain/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<String> syncRecord(RecordEntity record) async {
    if (ApiPaths.createRecord.isEmpty) {
      throw Exception('ApiPaths.createRecord no configurado');
    }
    final response = await _dio.post(ApiPaths.createRecord, data: record.payload);
    return response.data['id'].toString();
  }

  @override
  Future<void> uploadAudio(String recordRemoteId, String filePath) async {
    if (ApiPaths.uploadAudio.isEmpty) {
      throw Exception('ApiPaths.uploadAudio no configurado');
    }
    final form = FormData.fromMap({
      'record_id': recordRemoteId,
      'file': await MultipartFile.fromFile(filePath),
    });
    await _dio.post(ApiPaths.uploadAudio, data: form);
  }

  @override
  Future<void> uploadImage(String recordRemoteId, String filePath) async {
    if (ApiPaths.uploadImage.isEmpty) {
      throw Exception('ApiPaths.uploadImage no configurado');
    }
    final form = FormData.fromMap({
      'record_id': recordRemoteId,
      'file': await MultipartFile.fromFile(filePath),
    });
    await _dio.post(ApiPaths.uploadImage, data: form);
  }

  @override
  Future<void> uploadSignature(String recordRemoteId, String filePath) async {
    if (ApiPaths.uploadSignature.isEmpty) {
      throw Exception('ApiPaths.uploadSignature no configurado');
    }
    final form = FormData.fromMap({
      'record_id': recordRemoteId,
      'file': await MultipartFile.fromFile(filePath),
    });
    await _dio.post(ApiPaths.uploadSignature, data: form);
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return SyncRepositoryImpl(dio);
});
