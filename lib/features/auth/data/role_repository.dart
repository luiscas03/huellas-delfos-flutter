import 'package:supabase_flutter/supabase_flutter.dart';

class RoleRepository {
  RoleRepository(this._client);
  final SupabaseClient _client;

  Future<String?> getUserRole(String userId) async {
    final res = await _client.rpc('get_user_role', params: {'_user_id': userId}).maybeSingle();
    return res?.toString();
  }

  Future<bool> canAccessAdminPanel(String userId) async {
    final res = await _client.rpc('can_access_admin_panel', params: {'_user_id': userId}).maybeSingle();
    return res == true;
  }
}
