import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';

class EdgeFunctionsRepository {
  EdgeFunctionsRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> saveVisit(Map<String, dynamic> payload) async {
    final res = await _client.functions.invoke('save-visit', body: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> saveManualVisit(Map<String, dynamic> payload) async {
    final res = await _client.functions.invoke('save-manual-visit', body: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchScheduledVisits() async {
    final res = await _client.functions.invoke('fetch-scheduled-visits');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> syncGoogleSheets(Map<String, dynamic> payload) async {
    final res = await _client.functions.invoke('sync-google-sheets', body: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadToDrive(Map<String, dynamic> payload) async {
    final res = await _client.functions.invoke('upload-to-drive', body: payload);
    return res.data as Map<String, dynamic>;
  }
}

final edgeFunctionsRepositoryProvider = Provider<EdgeFunctionsRepository>((ref) {
  return EdgeFunctionsRepository(ref.read(supabaseProvider));
});
