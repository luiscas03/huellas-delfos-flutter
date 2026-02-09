import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_tables.dart';

class UserRepository {
  UserRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _client.from(SupabaseTables.profiles).select().eq('id', user.id).maybeSingle();
  }

  Future<Map<String, dynamic>?> getVisitorByUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final profile = await getProfile();
    final externalId = profile?['external_visitor_id'] as String?;
    if (externalId != null && externalId.isNotEmpty) {
      return _client.from(SupabaseTables.visitors).select().eq('id', externalId).maybeSingle();
    }
    final email = user.email;
    if (email == null) return null;
    return _client.from(SupabaseTables.visitors).select().eq('email', email).maybeSingle();
  }
}
