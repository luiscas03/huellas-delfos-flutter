import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_tables.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final res = await _client.from(SupabaseTables.profiles).select().eq('id', userId).maybeSingle();
    return res;
  }

  Future<Map<String, dynamic>?> getVisitorByEmail(String email) async {
    final res = await _client.from(SupabaseTables.visitors).select().eq('email', email).maybeSingle();
    return res;
  }

  Future<void> createProfile({required String userId, required String email, String? fullName}) async {
    await _client.from(SupabaseTables.profiles).insert({
      'id': userId,
      'email': email,
      'full_name': fullName ?? '',
    });
  }
}
