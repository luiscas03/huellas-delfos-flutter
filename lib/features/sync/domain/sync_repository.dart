import '../../records/domain/record_entity.dart';

abstract class SyncRepository {
  Future<String> syncRecord(RecordEntity record);
  Future<void> uploadImage(String recordRemoteId, String filePath);
  Future<void> uploadAudio(String recordRemoteId, String filePath);
  Future<void> uploadSignature(String recordRemoteId, String filePath);
}
