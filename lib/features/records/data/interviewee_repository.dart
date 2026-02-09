import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_tables.dart';

class IntervieweeRepository {
  IntervieweeRepository(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getByDocument(String documentId) async {
    return _client.from(SupabaseTables.interviewees).select().eq('document_id', documentId).maybeSingle();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await _client.from(SupabaseTables.interviewees).insert(data).select().single();
    return res;
  }
}
